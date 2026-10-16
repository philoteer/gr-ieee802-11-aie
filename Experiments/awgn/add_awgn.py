#!/usr/bin/env python3
"""Add reproducible AWGN to a ci16_le SigMF copy without running an analyzer.

Requires only NumPy. Supply an analyze_capture.py JSON report for calibrated
noise power, or specify complex time-domain noise power in int16 units directly.
"""

import argparse
import copy
import json
import math
from pathlib import Path

import numpy as np


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = ROOT / "AI-model-CNN-Channel-est/data/raw_capture/stress_test.sigmf-data"
DEFAULT_OUTPUT = Path(__file__).resolve().parent / "data/stress_test_awgn_15db.sigmf-data"


def noisy_copy(source, output, noise_power, seed, chunk_samples):
    """Stream interleaved int16 IQ, add independent real/imag AWGN, round, saturate."""
    rng = np.random.default_rng(seed)
    sigma = math.sqrt(noise_power / 2)
    clipped = 0
    samples = 0
    with source.open("rb") as reader, output.open("xb") as writer:
        while True:
            iq = np.fromfile(reader, dtype="<i2", count=2 * chunk_samples)
            if not len(iq):
                break
            values = iq.astype(np.float64)
            values += rng.normal(0, sigma, len(iq))
            np.rint(values, out=values)
            clipped += int(np.count_nonzero((values < -32768) | (values > 32767)))
            np.clip(values, -32768, 32767, out=values)
            values.astype("<i2").tofile(writer)
            samples += len(iq) // 2
    return {"samples": samples, "clipped_components": clipped,
            "clipped_component_fraction": clipped / (2 * samples)}


def inject_awgn(source, output, noise_power, seed=20261017, chunk_samples=1048576,
                target_snr_db=None):
    """Create data, updated metadata and an injection report; return the report."""
    if not math.isfinite(noise_power) or noise_power <= 0:
        raise ValueError("Noise power must be finite and positive; AWGN cannot increase SNR")
    if seed < 0 or chunk_samples < 1:
        raise ValueError("Seed must be nonnegative and chunk size must be positive")
    source, output = source.resolve(), output.resolve()
    metadata = json.loads(source.with_suffix(".sigmf-meta").read_text())
    fields = metadata["global"]
    if fields["core:datatype"] != "ci16_le" or fields.get("core:num_channels", 1) != 1:
        raise ValueError("Expected a single-channel ci16_le SigMF dataset")
    if source.stat().st_size == 0 or source.stat().st_size % 4:
        raise ValueError("Input must contain whole interleaved int16 I/Q samples")
    meta_output = output.with_suffix(".sigmf-meta")
    report_output = output.with_suffix(".awgn.json")
    if output.suffix != ".sigmf-data":
        raise ValueError("Output must have .sigmf-data suffix")
    if any(path.exists() for path in (output, meta_output, report_output)):
        raise ValueError("Output data, metadata or report already exists; choose a new output")
    output.parent.mkdir(parents=True, exist_ok=True)
    print(f"Writing {source.stat().st_size:,} bytes to {output}", flush=True)
    report = {"source": str(source), "output": str(output), "injection": {
        "target_snr_db": target_snr_db, "seed": seed,
        "complex_noise_power_int16_units": noise_power,
        "component_sigma_int16_units": math.sqrt(noise_power / 2),
        "chunk_samples": chunk_samples,
        **noisy_copy(source, output, noise_power, seed, chunk_samples)}}
    result = copy.deepcopy(metadata)
    result["global"].pop("core:sha512", None)
    result["global"]["core:dataset"] = output.name
    target_description = (f", target median LTS SNR {target_snr_db:g} dB"
                          if target_snr_db is not None else "")
    result["global"]["core:description"] = (
        fields.get("core:description", "")
        + f"; AWGN added{target_description}, seed {seed}; see {report_output.name}")
    meta_output.write_text(json.dumps(result, indent=2) + "\n")
    report_output.write_text(json.dumps(report, indent=2) + "\n")
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path,
                        help="input capture (default: report source, or original stress test)")
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    calibration = parser.add_mutually_exclusive_group(required=True)
    calibration.add_argument("--analysis-report", type=Path)
    calibration.add_argument("--noise-power", type=float,
                             help="E[|noise|²] in int16 IQ units; each component has half this variance")
    parser.add_argument("--seed", type=int, default=20261017)
    parser.add_argument("--chunk-samples", type=int, default=1048576)
    args = parser.parse_args()
    source = args.source
    target_snr_db = None
    noise_power = args.noise_power
    if args.analysis_report:
        analysis = json.loads(args.analysis_report.read_text())
        source = source or Path(analysis["source"])
        if source.resolve() != Path(analysis["source"]).resolve():
            parser.error("Analysis report belongs to a different source capture")
        noise_power = analysis["calibration"]["complex_noise_power_int16_units"]
        target_snr_db = analysis["calibration"]["target_snr_db"]
    try:
        report = inject_awgn(source or DEFAULT_SOURCE, args.output, noise_power,
                             args.seed, args.chunk_samples, target_snr_db)
    except ValueError as error:
        parser.error(str(error))
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
