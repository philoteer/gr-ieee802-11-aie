# Experiment energy logging

All six energy and realtime flowgraphs contain the same embedded **Run Energy
Logger** implementation. The logger has **no stream ports or Python streaming
work callback**. It does not add an IQ buffer reader, copy samples, or participate
in the stream scheduler.

Three Python snippets control its lifetime:

1. `energy_logger_prepare` takes the baseline before `top_block.start()`.
2. `energy_logger_start` starts the background sampler after native stream
   counters have been initialized.
3. `energy_logger_finish` takes the final reading and closes resources after
   `top_block.wait()`, including the generated SIGINT/SIGTERM shutdown path.

At the existing 0.5-second interval, the sampler reads sensors and polls a native
IQ sample counter once per snapshot. File experiments use the SigMF tag
injector's output count; realtime experiments use the USRP source's output
count. The CSV's `samples_processed` therefore describes **IQ input progress**,
not a count of decoded packets or samples consumed by every downstream stage.
There are no per-buffer Python calls for this counter.

Sysfs file handles are opened lazily, reused with seek/read, and closed when
logging finishes. CSV rows are buffered, with explicit flushes at the start,
end, and at most once every five seconds during the run. An abrupt process kill
can lose buffered rows; normal completion and SIGINT/SIGTERM flush the final
measurements. CSV fields and energy calculations remain compatible with the
existing report scripts.

For programmatic use, follow the same order:

```python
tb.epy_block_energy_logger.begin_logging()
tb.start()
tb.epy_block_energy_logger.start_monitoring(
    lambda: native_iq_source.nitems_written(0)
)
tb.wait()
tb.epy_block_energy_logger.finish_logging()
```

Compile each flowgraph into its own directory with `grcc -o <directory>
<flowgraph.grc>` before running. Regression checks use synthetic GNU Radio
streams and temporary sensor files, without starting a receiver or USRP:

```bash
python3 -m unittest discover -s Experiments -p test_energy_logger.py -v
```
