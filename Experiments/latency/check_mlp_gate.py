"""Check MLP bypass decisions from actual NPU SNR tags and decoded frame IDs.

This is a correctness check, not a latency benchmark. It runs file replay
unthrottled, using the saved MLP kernel without changing the gate or weights.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re

from gnuradio import blocks, gr, mlir_aie
import ieee802_11
import numpy as np
import pmt


ROOT = Path(__file__).resolve().parent
MODEL_DIR = ROOT.parents[1] / "AI-model-CNN-Channel-est/kernel/channel_estimator/model"


class FrameSNR(gr.sync_block):
    """Collect NPU SNR tags on first equalized payload vectors, before decoding."""

    def __init__(self):
        gr.sync_block.__init__(self, name="NPU frame SNR check",
                               in_sig=[(np.uint8, 48)], out_sig=None)
        self.values = []

    def work(self, input_items, output_items):
        count = len(input_items[0])
        for frame in self.get_tags_in_window(0, 0, count, pmt.intern("frame bytes")):
            tags = self.get_tags_in_range(0, frame.offset, frame.offset + 1, pmt.intern("snr"))
            if len(tags) != 1:
                raise RuntimeError("Expected one NPU SNR tag at each frame start")
            self.values.append(pmt.to_double(tags[0].value))
        return count


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--capture-base", type=Path, default=ROOT / "wifi_latency")
    parser.add_argument("--kernel-dir", type=Path,
                        default=ROOT.parent / "xclbin_default/MLP_BY_FRAME")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    base, kernel = args.capture_base.resolve(), args.kernel_dir.resolve()
    metadata = json.loads(Path(str(base) + ".sigmf-meta").read_text())
    with Path(str(base) + ".sigmf-data").open("rb") as stream:
        checksum = hashlib.file_digest(stream, "sha512").hexdigest()
    if checksum != metadata["global"]["core:sha512"]:
        raise ValueError("Capture data does not match the SigMF checksum")
    mode = dict(line.split("=", 1) for line in
                (kernel / "frame_equalizer_build_mode.txt").read_text().splitlines() if "=" in line)
    if mode.get("CNN_DATA_UPDATER") != "MLP" or mode.get("EQUALIZER_ALGORITHM") != "CNN":
        raise ValueError("Select a CNN channel estimator + MLP updater kernel")
    weights = mode["CNN_WEIGHTS"].lower()
    header = MODEL_DIR / f"frame_equalizer_channel_updater_mlp_weights_{weights}.h"
    gate = int(re.search(r"kGateSnrRatioX16\s*=\s*(\d+)", header.read_text()).group(1))
    # The native block exports 10*log10(raw/(2*16)). The LTS sum/difference
    # ratio includes a factor of two, so comparing raw/16 to dB would be wrong.
    gate_db = 10 * math.log10(gate / 32.0)
    cnn_header = MODEL_DIR / f"frame_equalizer_channel_ai_weights_{weights}.h"
    cnn_gate = int(re.search(r"kLsGateSnrRatioX16\s*=\s*(\d+)", cnn_header.read_text()).group(1))
    expected = {}
    for annotation in metadata["annotations"]:
        if annotation.get("core:label", "").startswith("wifi-frame-"):
            info = json.loads(annotation["core:comment"])
            expected[info["payload_ascii"].encode("ascii")] = info["mac_sequence_number"]
    # Derive the host batch size and 1024-sample tile count from the saved graph.
    graph = (kernel / "aie.mlir").read_text()
    vector_size = int(re.search(r"aie.runtime_sequence\(%arg0: memref<(\d+)xi16>", graph).group(1)) // 2
    tile_size = int(re.search(r"@frame_equalizer_out\([^\n]*memref<(\d+)xi8>", graph).group(1))
    top = gr.top_block()
    source = blocks.file_source(gr.sizeof_gr_complex, str(base) + ".sigmf-data", False)
    convert = mlir_aie.complex64_to_cint16(False)
    phy = mlir_aie.mlir_aie_80211_phy(str(kernel / "final.xclbin"), str(kernel / "insts.bin"),
                                    "MLIR_AIE", vector_size,
                                    metadata["captures"][0]["core:frequency"],
                                    2, vector_size // tile_size, "")
    vectors = blocks.stream_to_vector(gr.sizeof_char, 48)
    snr = FrameSNR()
    decoder = ieee802_11.decode_mac(False, False)
    pdus = blocks.message_debug()
    top.connect(source, convert, phy, vectors)
    top.connect(vectors, snr)
    top.connect(vectors, decoder)
    top.msg_connect((decoder, "out"), (pdus, "store"))
    top.start()
    top.wait()
    decoded = set()
    for i in range(pdus.num_messages()):
        mac = bytes(pmt.to_python(pmt.cdr(pdus.get_message(i))))
        payload = mac[24:]
        if payload not in expected or int.from_bytes(mac[22:24], "little") >> 4 != expected[payload]:
            raise RuntimeError("Decoded payload or sequence does not match annotations")
        if payload in decoded:
            raise RuntimeError("Duplicate decoded frame")
        decoded.add(payload)
    values = np.asarray(snr.values)
    if len(values) != len(expected):
        raise RuntimeError(f"Detected {len(values)}/{len(expected)} annotated frames")
    raw = np.rint(32.0 * np.power(10.0, values / 10.0)).astype(np.uint64)
    bypass = int(np.count_nonzero(raw >= gate))
    result = {
        "capture_base": str(base), "capture_sha512": metadata["global"]["core:sha512"],
        "kernel_dir": str(kernel), "kernel_mode": mode,
        "xclbin_sha256": hashlib.sha256((kernel / "final.xclbin").read_bytes()).hexdigest(),
        "vector_size": vector_size, "n_tiles": vector_size // tile_size,
        "expected_frames": len(expected), "detected_frames": len(values),
        "crc_valid_matching_frames": len(decoded),
        "mlp_gate_raw_threshold": gate, "mlp_gate_reported_snr_db": gate_db,
        "bypass_gate_taken_mlp_skipped": bypass,
        "bypass_gate_not_taken_mlp_runs": int(len(values) - bypass),
        "cnn_initial_estimator_skipped": int(np.count_nonzero(raw >= cnn_gate)),
        "snr_db": {"min": float(values.min()), "median": float(np.median(values)),
                   "max": float(values.max())},
        "raw_snr_ratio_x16": {"min": int(raw.min()), "max": int(raw.max())},
    }
    text = json.dumps(result, indent=2) + "\n"
    if args.report:
        args.report.write_text(text)
    print(text, end="")
    if len(decoded) != len(expected):
        raise SystemExit("Some annotated frames failed CRC/payload matching")


if __name__ == "__main__":
    main()
