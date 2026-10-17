# Throughput figures for an IEEE Access-style manuscript

Generate prepared data and figures from the repository root:

```sh
python3 Experiments/throughput/preprocess_throughput.py
python3 Experiments/throughput/plot_throughput.py
```

The plotter requires Matplotlib (`python3 -m pip install matplotlib`). It works
without a graphical display. Paths default relative to the scripts, independently
of the working directory. Input CSVs live in `throughput_csv/`; PNGs are written
to `figures/`, one per dataset. Rerunning replaces matching figure files.

Generate additional figures sized to fit **one column of a two-column paper**:

```sh
python3 Experiments/throughput/plot_throughput.py --columns single
```

These use `{dataset}_throughput_single_column.png`, preserving the existing
full-width `{dataset}_throughput.png` files. Use `--columns both` to generate
both sizes in one run. The default remains `--columns double`.

## Publication formatting

- Default: **600 dpi**, opaque white-background PNG, **7.16 × 4.2 inches**
  (4296 × 2520 pixels), intended for a two-column-wide figure.
- `--columns single` selects **3.5 × 4.5 inches** (**2100 × 2700 pixels** at
  600 dpi). The same point-size fonts and styles are used, rather than shrinking
  the full-width image. Three compact legend columns share one row, with extra
  width allocated to the baseline host labels and a single-row reference key.
  Shorter line samples preserve the 7 pt legend text; fewer X-axis ticks keep
  the narrow plot readable.
- Times New Roman is preferred; Nimbus Roman, Liberation Serif, and DejaVu Serif
  are fallbacks, in that order. The chosen installed font is printed.
- Axis labels are 9 pt, tick labels 8 pt, and legend text 7 pt at the saved size.
- Colors identify implementation families: blue for NPU and vermilion for
  `gr-ieee802-11`. Within both families, LS is solid, CNN dashed, and MLP
  dash-dot. Other implementations have individual colors and line styles for
  grayscale readability. These assignments remain consistent across datasets.
- Full-width figures use three titled legend groups (NPU, `gr-ieee802-11`, and
  other implementations), with a separate reference-line key beneath them.
- Baseline legend names identify both backend and evaluation host:
  `gr-ieee80211` is **CPU (NPU laptop)**, `gr-ieee80211_cu` is
  **CUDA (desktop PC)**, and `gr-ieee80211_desktop` is **CPU (desktop PC)**.
  The latter two share the same desktop host; all other implementations were
  evaluated on the NPU-enabled laptop, which is not CUDA-capable. Describe this
  hardware distinction in the manuscript when comparing throughput.
- No in-image title, caption, or figure number: supply these in LaTeX.
- Throughput uses an **11-reading centered moving average** by default, without
  downsampling. Windows shrink at recording edges and channel boundaries; no
  window mixes readings across a channel change. Readings are equally weighted,
  so the window's recording-time duration varies between runs. Prepared CSVs
  retain the raw data. State the smoothing window in the manuscript caption.
  Channel
  changes appear behind the curves as gray dashed lines, using companion
  `*_channel_changes.csv` files. No frequency labels are added to crowd the plot.
- The default 20 MSamples/s real-time reference matches the current 20 MHz
  recordings. Change `--reference-rate` for other input rates, or use 0 to hide it.

These are practical IEEE-style settings, not a substitute for checking the
current journal/template requirements. Insert at the intended width to preserve
readable physical font sizes. The fixed canvas is not tightly cropped, so its
physical dimensions and DPI are preserved. A different template width can slightly
change the effective resolution and text size when LaTeX scales the image.

Options include `--input-dir`, `--output-dir`, `--dpi`, `--columns`, `--height`
(inches), `--moving-average` (a positive odd number of readings; 1 disables
smoothing), and `--reference-rate` (MSamples/s). Example:

```sh
python3 Experiments/throughput/plot_throughput.py --columns single --height 4.5
```

## LaTeX inclusion

With `graphicx` loaded in the IEEE Access document, use a full-width figure:

```latex
\begin{figure*}[t]
    \centering
    \includegraphics[width=\textwidth]{Experiments/throughput/figures/206_throughput.png}
    \caption{Processing throughput for the 206 dataset, smoothed using an
    11-reading centered moving average within each channel segment. Vertical dashed lines
    indicate channel changes; the horizontal reference indicates the input
    recording rate.}
    \label{fig:206-throughput}
\end{figure*}
```

For a single-column figure in the same two-column document:

```latex
\begin{figure}[t]
    \centering
    \includegraphics[width=\columnwidth]{Experiments/throughput/figures/206_throughput_single_column.png}
    \caption{Processing throughput for the 206 dataset, using an 11-reading
    centered moving average within each channel segment. Vertical dashed lines
    indicate channel changes.}
    \label{fig:206-throughput-single}
\end{figure}
```

Adjust image paths relative to the document and use the journal template's
caption formatting. Choose either version in the manuscript for comparison.
The X-axis is **recording time**, not elapsed processing time; throughput reflects
the logged IQ progress, not decoded payload bitrate.
