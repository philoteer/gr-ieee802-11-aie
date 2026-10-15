"""Native tag forwarding and message-only reporter regression checks."""
import contextlib
import io
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from gnuradio import blocks, gr
import ieee802_11
import pmt
import yaml


ROOT = Path(__file__).resolve().parents[2]
graph = yaml.safe_load((ROOT / "original.grc").read_text())
source = next(b["parameters"]["_source_code"] for b in graph["blocks"]
              if b["name"] == "epy_block_latency")
namespace = {}
exec(compile(source, "original.grc:epy_block_latency", "exec"), namespace)


def boundary(frame, event, stamp):
    value = pmt.dict_add(pmt.make_dict(), pmt.intern("frame_id"),
                         pmt.intern(f"wifi-frame-{frame:08d}"))
    value = pmt.dict_add(value, pmt.intern("timestamp_ns"), pmt.from_uint64(stamp))
    return pmt.cons(pmt.intern("frame_" + event), value)


class NativeLatencyTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.meta = Path(self.temp.name) / "capture.sigmf-meta"
        annotations = [
            {"core:label": f"wifi-frame-{i:08d}",
             "core:comment": json.dumps({"payload_ascii": f"WIFI-LATENCY:{i:08d}",
                                         "mac_sequence_number": i})}
            for i in range(3)
        ]
        self.meta.write_text(json.dumps({"annotations": annotations}))
        self.output = io.StringIO()
        self.redirect = contextlib.redirect_stdout(self.output)
        self.redirect.__enter__()
        self.addCleanup(self.redirect.__exit__, None, None, None)
        self.reporter = namespace["blk"](str(self.meta))

    def decoded(self, frame, completed, sequence=None):
        mac = bytearray(24)
        mac[22:24] = ((frame if sequence is None else sequence) << 4).to_bytes(2, "little")
        mac.extend(f"WIFI-LATENCY:{frame:08d}".encode("ascii"))
        meta = pmt.make_dict()
        if completed is not None:
            meta = pmt.dict_add(meta, pmt.intern("phy_completed_ns"),
                                pmt.from_uint64(completed))
        message = pmt.cons(meta, pmt.init_u8vector(len(mac), list(mac)))
        # A much later Python observation must never replace native completion.
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
        monitor = ieee802_11.latency_tag_monitor()
        sink = blocks.message_debug()
        top.connect(src, monitor)
        top.msg_connect((monitor, "events"), (sink, "store"))
        top.start()
        top.wait()
        self.assertEqual(sink.num_messages(), 2)
        for index in range(2):
            value = pmt.cdr(sink.get_message(index))
            stamp = pmt.to_uint64(pmt.dict_ref(value, pmt.intern("timestamp_ns"), pmt.PMT_NIL))
            self.assertEqual(stamp, 1_000_000 + index)

    def test_reordered_messages_loss_duplicates_and_late_python(self):
        self.decoded(2, 25_000_000)  # Completion can arrive before both boundaries.
        for frame, stamp in ((0, 1_000_000), (1, 10_000_000), (2, 20_000_000)):
            self.reporter.handle_boundary(boundary(frame, "start", stamp))
            self.reporter.handle_boundary(boundary(frame, "end", stamp + 1_000_000))
        self.decoded(1, 13_000_000)
        self.decoded(2, 26_000_000)
        self.decoded(0, 30_000_000, sequence=99)
        self.assertEqual(self.reporter.count, 2)
        self.assertEqual(self.reporter.total_ms, 8.0)
        self.assertEqual(self.reporter.duplicates, 1)
        self.assertEqual(self.reporter.unmatched, 1)
        state = self.reporter.frames["wifi-frame-00000002"]
        self.assertEqual(state["done"], 25_000_000)
        self.assertEqual(state["observed"], 10_000_000_000)
        self.reporter.finish()
        self.assertIn("missing: wifi-frame-00000000", self.output.getvalue())

    def test_rejects_decoder_without_native_timestamp(self):
        with self.assertRaisesRegex(RuntimeError, "phy_completed_ns"):
            self.decoded(1, None)


if __name__ == "__main__":
    unittest.main()
