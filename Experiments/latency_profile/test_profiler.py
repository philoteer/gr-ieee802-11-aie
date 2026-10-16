"""Hardware-free checks. Run through run-profile.sh after build-local.sh."""

import csv
import os
import tempfile
import unittest
from pathlib import Path

from gnuradio import blocks

from profiler_support import ProfileSession, summarize_intra


class ProfileTests(unittest.TestCase):
    def test_summary_separates_overlapping_metrics(self):
        with tempfile.TemporaryDirectory() as directory:
            raw = Path(directory) / "raw.csv"
            summary = Path(directory) / "summary.csv"
            with raw.open("w", newline="") as stream:
                writer = csv.writer(stream)
                writer.writerow(("scope", "stage", "duration_ns"))
                writer.writerows((("chunk", "run_wait", 100),
                                  ("chunk", "run_wait", 300),
                                  ("chunk", "submit_to_wait_complete", 800),
                                  ("work", "work_total", 1000)))
            summarize_intra(raw, summary)
            with summary.open(newline="") as stream:
                rows = {(r["scope"], r["stage"]): r for r in csv.DictReader(stream)}
            wait = rows["chunk", "run_wait"]
            self.assertEqual(int(wait["count"]), 2)
            self.assertEqual(int(wait["total_ns"]), 400)
            self.assertEqual(float(wait["mean_ns"]), 200)
            self.assertEqual(float(wait["stddev_ns"]), 100)
            self.assertEqual(int(rows["work", "work_total"]["total_ns"]), 1000)

    @unittest.skipUnless(os.environ.get("PROFILE_TEST_HARDWARE") == "1", "NPU test is opt-in")
    def test_hardware_multislot_profile_preserves_output(self):
        from npu_intra_kernel import npu_intra_kernel

        with tempfile.TemporaryDirectory() as directory:
            old_output = os.environ.get("PROFILE_OUTPUT_DIR")
            os.environ["PROFILE_OUTPUT_DIR"] = directory
            try:
                def run(profile):
                    tb = npu_intra_kernel(num_samples=1048576)
                    phy = tb.mlir_aie_mlir_aie_80211_phy_0
                    # Exercise both initial launches and slot reuse in one work call.
                    phy.set_output_multiple(65536)
                    sink = blocks.vector_sink_b()
                    tb.connect(phy, sink)
                    session = ProfileSession(tb, tb.output_dir) if profile else None
                    tb.start()
                    tb.wait()
                    if session:
                        session.finish()
                    return list(sink.data())

                baseline = run(False)
                measured = run(True)
                self.assertTrue(baseline, "Capture must produce symbols to check data integrity")
                self.assertEqual(baseline, measured)
                with (Path(directory) / "intra/intra_raw.csv").open(newline="") as stream:
                    rows = list(csv.DictReader(stream))
                chunks = [r for r in rows if r["stage"] == "run_wait"]
                self.assertEqual(len(chunks), 64)
                self.assertEqual([int(r["input_offset"]) for r in chunks],
                                 list(range(0, 1048576, 16384)))
                self.assertGreaterEqual(max(int(r["chunk_index"]) for r in chunks), 3)
                self.assertEqual(sum(int(r["output_items"]) for r in chunks), len(measured))
                work = {}
                for row in rows:
                    self.assertGreaterEqual(int(row["duration_ns"]), 0)
                    if row["scope"] == "work":
                        work.setdefault(row["work_id"], {})[row["stage"]] = int(row["duration_ns"])
                for stages in work.values():
                    self.assertEqual(stages["work_total"],
                                     stages["prepare"] + stages["pipeline"] + stages["finalize"])
            finally:
                if old_output is None:
                    os.environ.pop("PROFILE_OUTPUT_DIR", None)
                else:
                    os.environ["PROFILE_OUTPUT_DIR"] = old_output


if __name__ == "__main__":
    unittest.main()
