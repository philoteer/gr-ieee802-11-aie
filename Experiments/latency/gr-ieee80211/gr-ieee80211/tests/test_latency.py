"""Test native boundary forwarding and GR-WiFi envelope/timestamp matching."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zlib

from gnuradio import blocks, gr, ieee80211
import pmt
import yaml


ROOT = Path(__file__).resolve().parents[2]
graph = yaml.safe_load((ROOT / "s80211.grc").read_text())
source = next(b["parameters"]["_source_code"] for b in graph["blocks"]
              if b["name"] == "epy_block_latency")
namespace = {}
exec(compile(source, "s80211.grc:epy_block_latency", "exec"), namespace)


def boundary(frame, event, stamp):
    value = pmt.dict_add(pmt.make_dict(), pmt.intern("frame_id"),
                         pmt.intern(f"wifi-frame-{frame:08d}"))
    value = pmt.dict_add(value, pmt.intern("timestamp_ns"), pmt.from_uint64(stamp))
    return pmt.cons(pmt.intern("frame_" + event), value)


class NativeLatencyTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        meta = Path(self.temp.name) / "capture.sigmf-meta"
        meta.write_text(json.dumps({"annotations": [
            {"core:label": f"wifi-frame-{i:08d}",
             "core:comment": json.dumps({"payload_ascii": f"WIFI-LATENCY:{i:08d}",
                                         "mac_sequence_number": i})}
            for i in range(3)
        ]}))
        self.output = io.StringIO()
        redirect = contextlib.redirect_stdout(self.output)
        redirect.__enter__()
        self.addCleanup(redirect.__exit__, None, None, None)
        self.reporter = namespace["blk"](str(meta))

    def decoded(self, frame, completed, sequence=None, corrupt=None, fmt=0):
        mac = bytearray(24)
        mac[22:24] = ((frame if sequence is None else sequence) << 4).to_bytes(2, "little")
        mac.extend(f"WIFI-LATENCY:{frame:08d}".encode("ascii"))
        psdu = mac + zlib.crc32(mac).to_bytes(4, "little")
        packet = bytearray([fmt]) + len(psdu).to_bytes(2, "little") + psdu + bytes([0])
        if corrupt == "length":
            packet[1] += 1
        elif corrupt == "fcs":
            packet[-2] ^= 1
        metadata = pmt.make_dict()
        if completed is not None:
            metadata = pmt.dict_add(metadata, pmt.intern("phy_equalized_ns"),
                                    pmt.from_uint64(completed))
        message = pmt.cons(metadata, pmt.init_u8vector(len(packet), list(packet)))
        with patch.object(namespace["time"], "monotonic_ns", return_value=10_000_000_000):
            self.reporter.handle_decoded(message)

    def test_native_monitor_preserves_original_timestamp(self):
        tags = []
        for offset, event in enumerate(("start", "end")):
            message = boundary(1, event, 1_000_000 + offset)
            tag = gr.tag_t()
            tag.offset, tag.key, tag.value = offset, pmt.car(message), pmt.cdr(message)
            tags.append(tag)
        top = gr.top_block()
        src = blocks.vector_source_c([0j] * 16, False, 1, tags)
        monitor = ieee80211.latency_tag_monitor()
        sink = blocks.message_debug()
        top.connect(src, monitor)
        top.msg_connect((monitor, "events"), (sink, "store"))
        top.start()
        top.wait()
        self.assertEqual(sink.num_messages(), 2)
        for index in range(2):
            stamp = pmt.dict_ref(pmt.cdr(sink.get_message(index)),
                                  pmt.intern("timestamp_ns"), pmt.PMT_NIL)
            self.assertEqual(pmt.to_uint64(stamp), 1_000_000 + index)

    def test_reordered_lost_duplicate_and_late_python(self):
        self.decoded(2, 25_000_000, fmt=2)
        for frame, stamp in ((0, 1_000_000), (1, 10_000_000), (2, 20_000_000)):
            self.reporter.handle_boundary(boundary(frame, "end", stamp + 1_000_000))
            self.reporter.handle_boundary(boundary(frame, "start", stamp))
        self.decoded(1, 13_000_000, fmt=1)
        self.decoded(2, 26_000_000)
        self.decoded(0, 30_000_000, sequence=99)
        self.assertEqual(self.reporter.count, 2)
        self.assertEqual(self.reporter.total_ms, 8.0)
        self.assertEqual(self.reporter.duplicates, 1)
        self.assertEqual(self.reporter.unmatched, 1)
        self.assertEqual(self.reporter.malformed, 0)
        state = self.reporter.frames["wifi-frame-00000002"]
        self.assertEqual(state["done"], 25_000_000)
        self.assertEqual(state["observed"], 10_000_000_000)
        self.reporter.finish()
        self.assertIn("missing: wifi-frame-00000000", self.output.getvalue())

    def test_rejects_bad_envelope_or_fcs_and_ignores_channel_reports(self):
        self.decoded(1, 13_000_000, corrupt="length")
        self.decoded(1, 13_000_000, corrupt="fcs")
        self.decoded(1, None, fmt=20)
        self.assertEqual(self.reporter.malformed, 2)
        self.assertNotIn("done", self.reporter.frames["wifi-frame-00000001"])

    def test_rejects_decoder_without_native_timestamp(self):
        with self.assertRaisesRegex(RuntimeError, "phy_equalized_ns"):
            self.decoded(1, None)

    def test_decoder_preserves_equalizer_timestamp(self):
        # Supply padding for the receiver's original forecast. This tests only
        # timestamp forwarding from a later LLR tag into the decoded PDU.
        values = {"format": 0, "len": 4, "total": 512, "cr": 0,
                  "mcs": 0, "ampdu": 0, "trellis": 72}
        tags = []
        for key, value in values.items():
            tag = gr.tag_t()
            tag.offset, tag.key, tag.value = 0, pmt.intern(key), pmt.from_long(value)
            tags.append(tag)
        completion = gr.tag_t()
        completion.offset = 100
        completion.key = pmt.intern("phy_equalized_ns")
        completion.value = pmt.from_uint64(123456789)
        tags.append(completion)
        top = gr.top_block()
        source = blocks.vector_source_f([0.0] * 512, False, 1, tags)
        decoder = ieee80211.decode(False)
        messages = blocks.message_debug()
        top.connect(source, decoder)
        top.msg_connect((decoder, "out"), (messages, "store"))
        top.start()
        top.wait()
        self.assertEqual(messages.num_messages(), 1)
        metadata = pmt.car(messages.get_message(0))
        self.assertEqual(pmt.to_uint64(pmt.dict_ref(
            metadata, pmt.intern("phy_equalized_ns"), pmt.PMT_NIL)), 123456789)
        self.assertFalse(pmt.dict_has_key(metadata, pmt.intern("phy_completed_ns")))


if __name__ == "__main__":
    unittest.main()
