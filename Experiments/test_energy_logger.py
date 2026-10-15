"""Regression checks for the portless logger embedded in every experiment."""

import csv
from pathlib import Path
import tempfile
import time
import unittest
from unittest.mock import Mock, patch

from gnuradio import blocks, gr
import yaml


EXPERIMENTS = Path(__file__).resolve().parent


def flowgraphs():
    """Load flowgraphs and their active blocks without creating a receiver."""
    for path in sorted(EXPERIMENTS.rglob("*.grc")):
        graph = yaml.safe_load(path.read_text())
        active = {b["name"]: b for b in graph["blocks"]
                  if b["states"]["state"] == "enabled"}
        if "epy_block_energy_logger" in active:
            yield path, graph, active


def logger_namespace():
    """Interpret one embedded logger without accessing sensors or hardware."""
    _, _, active = next(flowgraphs())
    namespace = {}
    exec(active["epy_block_energy_logger"]["parameters"]["_source_code"], namespace)
    return namespace


class EnergyLoggerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.rapl = self.root / "rapl"
        self.battery = self.root / "supplies/BAT0"
        self.ac = self.root / "supplies/AC"
        for path in (self.rapl, self.battery, self.ac):
            path.mkdir(parents=True)
        self.write(self.rapl, name="package-0", energy_uj="900000",
                   max_energy_range_uj="1000000")
        self.write(self.battery, type="Battery", status="Discharging",
                   power_now="10000000", energy_now="50000000")
        self.write(self.ac, type="Mains", online="0")
        self.csv = self.root / "energy.csv"
        self.namespace = logger_namespace()

    @staticmethod
    def write(directory, **values):
        for name, value in values.items():
            (directory / name).write_text(value)

    def make_logger(self, interval=60):
        logger = self.namespace["blk"](
            str(self.csv), interval, str(self.rapl), str(self.root / "supplies"))
        self.addCleanup(logger.finish_logging)
        return logger

    def rows(self):
        with self.csv.open(newline="") as stream:
            return list(csv.DictReader(stream))

    def test_all_copies_and_lifecycle_connections(self):
        sources = []
        graphs = list(flowgraphs())
        self.assertEqual(len(graphs), 6)
        for path, graph, active in graphs:
            with self.subTest(path=path):
                sources.append(active["epy_block_energy_logger"]["parameters"]["_source_code"])
                self.assertFalse(any("epy_block_energy_logger" in (c[0], c[2])
                                     for c in graph["connections"]))
                for name, section in (("prepare", "main_after_init"),
                                      ("start", "main_after_start"),
                                      ("finish", "main_after_stop")):
                    self.assertEqual(active[f"energy_logger_{name}"]["parameters"]["section"],
                                     section)
                source = ("uhd_usrp_source_0" if "realtime" in path.parts
                          else "mlir_aie_sigmf_tag_injector_0")
                self.assertIn(source, active)
                self.assertIn(f"self.{source}.nitems_written(0)",
                              active["energy_logger_start"]["parameters"]["code"])
        self.assertEqual(len(set(sources)), 1)
        logger = self.make_logger()
        self.assertEqual(list(logger.in_sig()), [])
        self.assertEqual(list(logger.out_sig()), [])
        self.assertNotIn("work", self.namespace["blk"].__dict__)

    def test_wraparound_and_ac_transition_with_cached_sensors(self):
        logger = self.make_logger()
        counter = Mock(return_value=4096)
        with patch.object(self.namespace["time"], "monotonic_ns",
                          side_effect=[1_000_000_000, 2_000_000_000,
                                       3_000_000_000, 4_000_000_000]):
            logger.begin_logging()
            counter.assert_not_called()
            handles = dict(logger._sensor_files)
            logger.start_monitoring(counter)
            self.write(self.rapl, energy_uj="100000")
            logger._sample("sample")
            self.write(self.ac, online="1")
            self.write(self.rapl, energy_uj="200000")
            logger._sample("sample")
            self.assertEqual(handles, logger._sensor_files)
            self.write(self.rapl, energy_uj="300000")
            counter.return_value = 8192
            logger.finish_logging()
        rows = self.rows()
        self.assertAlmostEqual(float(rows[1]["soc_power_w"]), 0.2)
        self.assertAlmostEqual(float(rows[-1]["soc_energy_j"]), 0.4)
        self.assertEqual(rows[2]["system_power_w"], "")
        self.assertEqual(rows[-1]["samples_processed"], "8192")
        self.assertEqual(counter.call_count, 3)
        self.assertTrue(all(stream.closed for stream in handles.values()))
        self.assertFalse(logger._sensor_files)

    def test_native_progress_and_eof_without_stream_reader(self):
        logger = self.make_logger(interval=0.05)
        graph = gr.top_block()
        source = blocks.vector_source_c([1j] * 4096, False)
        graph.connect(source, blocks.null_sink(gr.sizeof_gr_complex))
        logger.begin_logging()
        graph.start()
        logger.start_monitoring(lambda: source.nitems_written(0))
        graph.wait()
        self.assertIsNotNone(logger._file)
        time.sleep(0.12)  # Downstream draining does not prematurely close logging.
        logger.finish_logging()
        logger.finish_logging()
        rows = self.rows()
        self.assertEqual(rows[0]["phase"], "start")
        self.assertEqual(rows[-1]["phase"], "end")
        self.assertEqual(int(rows[-1]["samples_processed"]), 4096)
        self.assertGreaterEqual(len(rows), 3)
        self.assertFalse(logger._thread.is_alive())

    def test_csv_flushes_are_batched(self):
        logger = self.make_logger()
        with patch.object(self.namespace["time"], "monotonic_ns",
                          side_effect=[1_000_000_000, 2_000_000_000,
                                       3_000_000_000, 7_000_000_000, 8_000_000_000]):
            logger.begin_logging()
            actual_file = logger._file
            logger._file = Mock(wraps=actual_file)
            output = logger._file
            logger._sample("sample")
            logger._sample("sample")
            output.flush.assert_not_called()
            logger._sample("sample")
            self.assertEqual(output.flush.call_count, 1)
            logger.finish_logging()
            self.assertEqual(output.flush.call_count, 2)
        self.assertEqual(len(self.rows()), 5)

    def test_failed_start_releases_sensor_handles(self):
        self.write(self.rapl, energy_uj="invalid")
        logger = self.make_logger()
        with self.assertRaises(ValueError):
            logger.begin_logging()
        self.assertIsNone(logger._file)
        self.assertFalse(logger._sensor_files)

    def test_sampling_error_is_reported_and_cleans_up(self):
        logger = self.make_logger(interval=0.05)
        logger.begin_logging()
        handles = list(logger._sensor_files.values())
        self.write(self.rapl, energy_uj="invalid")
        logger.start_monitoring(lambda: 0)
        logger._thread.join(timeout=2)
        self.assertIsInstance(logger._error, ValueError)
        with self.assertRaisesRegex(RuntimeError, "Energy sampling failed"):
            logger.finish_logging()
        self.assertTrue(all(stream.closed for stream in handles))
        self.assertEqual(self.rows()[-1]["phase"], "start")


if __name__ == "__main__":
    unittest.main()
