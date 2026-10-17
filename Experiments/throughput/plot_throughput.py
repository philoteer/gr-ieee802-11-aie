#!/usr/bin/env python3
"""Generate publication-sized, 600 dpi throughput PNGs from prepared CSVs.

Run preprocess_throughput.py first. Each dataset becomes a separate figure with
recording-time coordinates, moving-average throughput, and channel markers.
Figure captions and numbering belong in the surrounding LaTeX document.
"""

import argparse
from bisect import bisect_left
import csv
import math
from pathlib import Path

import matplotlib

# Support batch generation on machines without a graphical display.
matplotlib.use("Agg")
from matplotlib import font_manager
from matplotlib import pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.ticker import MaxNLocator


SCRIPT_DIR = Path(__file__).resolve().parent
FAMILY_COLORS = {"NPU": "#0072B2", "gr-ieee802-11": "#D55E00",
                 "gr-ieee80211": "#009E73", "gr-ieee80211_cu": "#8B5AA5",
                 "gr-ieee80211_desktop": "#6B4C2A"}
MODEL_STYLES = {"LS": "-", "CNN": (0, (5, 2)), "MLP": (0, (3, 1.5, 1, 1.5))}
BASELINE_STYLES = {"gr-ieee80211": (0, (1, 1.5)),
                   "gr-ieee80211_cu": (0, (6, 2)),
                   "gr-ieee80211_desktop": "-"}
BASELINE_LABELS = {"gr-ieee80211": "CPU (NPU laptop)",
                   "gr-ieee80211_cu": "CUDA (desktop PC)",
                   "gr-ieee80211_desktop": "CPU (desktop PC)"}


def read_series(path):
    """Read independent X/Y throughput pairs, excluding spreadsheet markers.

    Args:
        path (Path): Dataset throughput CSV written by the preprocessor.

    Returns:
        dict: Run labels mapped to lists of (recording_s, MSamples/s) pairs.

    Raises:
        OSError: If the CSV cannot be read.
        ValueError: If columns or coordinate values are invalid or empty.
    """
    with path.open(newline="") as stream:
        reader = csv.DictReader(stream)
        fields = reader.fieldnames or []
        labels = [field.removesuffix(":throughput_MSamples_s") for field in fields
                  if field.endswith(":throughput_MSamples_s")]
        if not labels:
            raise ValueError(f"{path}: no throughput series")
        for label in labels:
            if f"{label}:recording_s" not in fields:
                raise ValueError(f"{path}: missing X column for {label}")
        series = {label: [] for label in labels}
        for row in reader:
            for label in labels:
                x, y = row[f"{label}:recording_s"], row[f"{label}:throughput_MSamples_s"]
                if x == "" and y == "":
                    continue
                x, y = float(x), float(y)
                if not all(math.isfinite(value) and value >= 0 for value in (x, y)):
                    raise ValueError(f"{path}: invalid coordinate for {label}")
                if series[label] and x < series[label][-1][0]:
                    raise ValueError(f"{path}: decreasing recording time for {label}")
                series[label].append((x, y))
    if any(not points for points in series.values()):
        raise ValueError(f"{path}: empty throughput series")
    return series


def read_changes(path):
    """Read channel-change recording times from a companion CSV.

    Args:
        path (Path): Companion dataset channel-change CSV.

    Returns:
        list[float]: Channel-change positions in recording seconds.

    Raises:
        OSError: If the CSV cannot be read.
        KeyError: If a channel-change row lacks recording_s.
        ValueError: If a position is invalid.
    """
    with path.open(newline="") as stream:
        times = [float(row["recording_s"]) for row in csv.DictReader(stream)]
    if any(not math.isfinite(value) or value < 0 for value in times):
        raise ValueError(f"{path}: invalid channel-change time")
    return times


def select_font():
    """Return the first installed Times-style font, with a portable fallback.

    Returns:
        str: Matplotlib font family name.
    """
    available = {font.name for font in font_manager.fontManager.ttflist}
    for family in ("Times New Roman", "Nimbus Roman", "Liberation Serif"):
        if family in available:
            return family
    return "DejaVu Serif"


def moving_average(points, changes, window):
    """Smooth throughput within channel segments using a centered mean.

    Args:
        points (list[tuple]): Ordered (recording_s, MSamples/s) readings.
        changes (list[float]): Channel-change positions in recording seconds.
        window (int): Positive odd number of readings per window. One disables
            smoothing. Windows shrink at recording and channel-segment edges.

    Returns:
        list[tuple]: Original X coordinates paired with arithmetic-mean
        throughput values. No window includes readings across a channel change.
        Readings are equally weighted; spacing in recording time may vary.

    Raises:
        ValueError: If the window is not positive and odd.
    """
    if window < 1 or window % 2 == 0:
        raise ValueError("Moving-average window must be positive and odd")
    x = [time for time, _ in points]
    boundaries = [0] + [bisect_left(x, time) for time in sorted(changes)] + [len(points)]
    smoothed = []
    radius = window // 2
    for start, stop in zip(boundaries, boundaries[1:]):
        # Prefix sums keep averaging linear in the number of readings.
        totals = [0.0]
        for _, value in points[start:stop]:
            totals.append(totals[-1] + value)
        for index in range(start, stop):
            left = max(start, index - radius)
            right = min(stop, index + radius + 1)
            mean = (totals[right - start] - totals[left - start]) / (right - left)
            smoothed.append((points[index][0], mean))
    return smoothed


def display_label(label):
    """Shorten a run identifier for the legend without changing its identity.

    Args:
        label (str): Implementation/results-directory identifier.

    Returns:
        str: Human-readable legend label.
    """
    implementation, _, results = label.partition("/")
    model = results.removeprefix("results").lstrip("_-")
    name = BASELINE_LABELS.get(implementation, implementation)
    return f"{name} / {model}" if model else name


def run_identity(label):
    """Return a run's legend group and within-group name.

    Args:
        label (str): Implementation/results-directory identifier.

    Returns:
        tuple[str, str]: Legend group and model or implementation name.
    """
    implementation, _, results = label.partition("/")
    model = results.removeprefix("results").lstrip("_-")
    if implementation in ("NPU", "gr-ieee802-11"):
        return implementation, model or results
    return "gr-ieee80211", display_label(label)


def create_layout(columns, height=None):
    """Create publication-sized axes with dedicated grouped-legend space.

    Args:
        columns (str): "single" for one journal column or "double" for both.
        height (float | None): Optional figure height in inches.

    Returns:
        tuple: Figure, plotting axes, three group-legend axes, and reference-key
        axes. Single-column legends use unequal column widths to accommodate
        baseline host names without shrinking fonts.
    """
    width = 7.16 if columns == "double" else 3.5
    height = height or (4.2 if columns == "double" else 4.5)
    fig = plt.figure(figsize=(width, height), layout="constrained")
    if columns == "double":
        grid = fig.add_gridspec(3, 3, height_ratios=(0.65, 0.22, 3.0))
    else:
        grid = fig.add_gridspec(3, 3, height_ratios=(0.55, 0.16, 3.4),
                               width_ratios=(0.65, 0.95, 1.65))
    legend_axes = [fig.add_subplot(grid[0, column]) for column in range(3)]
    reference_ax = fig.add_subplot(grid[1, :])
    ax = fig.add_subplot(grid[2, :])
    for legend_ax in legend_axes + [reference_ax]:
        legend_ax.set_axis_off()
    return fig, ax, legend_axes, reference_ax


def plot_dataset(path, output_dir, styles, args, columns):
    """Render one dataset at its intended physical publication size.

    Args:
        path (Path): Prepared throughput CSV.
        output_dir (Path): Existing PNG destination directory.
        styles (dict): Global run-label mapping to color/line-style pairs.
        args (argparse.Namespace): Plot size, resolution, and reference settings.
        columns (str): "single" or "double" publication layout.

    Raises:
        OSError: If an input cannot be read or the figure cannot be saved.
        ValueError: If the input coordinates are invalid.
        KeyError: If a required field or style is missing.
    """
    series = read_series(path)
    dataset = path.name.removesuffix("_throughput.csv")
    changes = read_changes(path.with_name(f"{dataset}_channel_changes.csv"))
    fig, ax, legend_axes, reference_ax = create_layout(columns, args.height)
    width, height = fig.get_size_inches()
    try:
        xmax = max(points[-1][0] for points in series.values())
        groups = {name: [] for name in ("NPU", "gr-ieee802-11", "gr-ieee80211")}
        model_order = {"LS": 0, "CNN": 1, "MLP": 2}
        ordered = sorted(series, key=lambda label: (
            list(groups).index(run_identity(label)[0]),
            model_order.get(run_identity(label)[1], 3), label))
        for label in ordered:
            points = series[label]
            color, linestyle = styles[label]
            x, y = zip(*moving_average(points, changes, args.moving_average))
            line, = ax.plot(x, y, color=color, linestyle=linestyle, linewidth=0.95,
                            label=display_label(label), zorder=3)
            group, short_label = run_identity(label)
            groups[group].append((line, short_label))
        visible_changes = [time for time in changes if time <= xmax]
        for time in visible_changes:
            ax.axvline(time, color="0.55", linestyle=(0, (3, 3)),
                       linewidth=0.6, zorder=1)
        references = []
        if args.reference_rate > 0:
            reference = ax.axhline(args.reference_rate, color="0.25", linestyle=(0, (8, 4)),
                       linewidth=0.8, zorder=2,
                       label=f"Real-time reference ({args.reference_rate:g} MSamples/s)")
            references.append((reference, reference.get_label()))
        if visible_changes:
            references.append((Line2D([], [], color="0.55", linestyle=(0, (3, 3)),
                                      linewidth=0.6), "Channel change"))
        legend_options = dict(frameon=False, fontsize=7, handlelength=3.5,
                              borderaxespad=0, labelspacing=0.4)
        if columns == "single":
            legend_options.update(handlelength=2.3, handletextpad=0.5,
                                  labelspacing=0.3, borderpad=0.1,
                                  columnspacing=1.0)
        for legend_ax, (group, entries) in zip(legend_axes, groups.items()):
            if entries:
                handles, labels = zip(*entries)
                legend = legend_ax.legend(handles, labels, title=group,
                                          title_fontsize=8, loc="upper center",
                                          **legend_options)
                legend.get_title().set_weight("bold")
        if references:
            handles, labels = zip(*references)
            if columns == "single":
                labels = [label.replace("Real-time reference", "Real-time") for label in labels]
            reference_ax.legend(handles, labels, ncol=2,
                                loc="center", **legend_options)
        ax.set_xlabel("Recording time (s)")
        ax.set_ylabel("Processing throughput (MSamples/s)")
        ax.set_xlim(0, xmax if xmax > 0 else 1)
        ax.set_ylim(bottom=0)
        ax.xaxis.set_major_locator(MaxNLocator(nbins=7 if columns == "double" else 4))
        ax.grid(axis="y", color="0.9", linewidth=0.4, zorder=0)
        ax.spines[["top", "right"]].set_visible(False)
        # Preserve the requested physical dimensions; tight bounding boxes would
        # change the PNG size and hence its effective font size in LaTeX.
        suffix = "_single_column" if columns == "single" else ""
        destination = output_dir / f"{dataset}_throughput{suffix}.png"
        fig.savefig(destination, dpi=args.dpi, facecolor="white", transparent=False)
        print(f"{destination}: {width:g} x {height:g} in, {args.dpi} dpi; "
              f"{len(series)} runs, {len(visible_changes)} channel changes; "
              f"moving average: {args.moving_average} readings")
    finally:
        plt.close(fig)


def main():
    """Parse plotting options and generate a consistently styled figure set.

    Raises:
        SystemExit: If arguments or plotting inputs are invalid.
    """
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input-dir", type=Path, default=SCRIPT_DIR / "throughput_csv")
    parser.add_argument("--output-dir", type=Path, default=SCRIPT_DIR / "figures")
    parser.add_argument("--dpi", type=int, default=600)
    parser.add_argument("--columns", choices=("single", "double", "both"), default="double",
                        help="publication width; single uses separate filenames; "
                             "both generates both layouts (default: double)")
    parser.add_argument("--height", type=float, help="figure height in inches")
    parser.add_argument("--moving-average", type=int, default=11, metavar="READINGS",
                        help="centered moving-average window, positive and odd "
                             "(default: 11); 1 plots raw readings")
    parser.add_argument("--reference-rate", type=float, default=20,
                        help="real-time input rate in MSamples/s; 0 disables the line")
    args = parser.parse_args()
    if args.moving_average < 1 or args.moving_average % 2 == 0:
        parser.error("--moving-average must be positive and odd")
    if args.dpi <= 0 or (args.height is not None and
                         (not math.isfinite(args.height) or args.height <= 0)):
        parser.error("DPI and height must be positive and finite")
    if not math.isfinite(args.reference_rate) or args.reference_rate < 0:
        parser.error("reference rate must be finite and nonnegative")
    try:
        paths = sorted(args.input_dir.glob("*_throughput.csv"))
        if not paths:
            raise ValueError(f"No *_throughput.csv files in {args.input_dir}")
        # Assign styles across all datasets so absent runs never shift colors.
        labels = sorted({label for path in paths for label in read_series(path)})
        styles = {label: (FAMILY_COLORS.get(label.partition("/")[0], "#444444"),
                          MODEL_STYLES.get(run_identity(label)[1],
                              BASELINE_STYLES.get(label.partition("/")[0], "-")))
                  for label in labels}
        font = select_font()
        plt.rcParams.update({"font.family": "serif", "font.serif": [font],
                             "font.size": 8, "axes.labelsize": 9,
                             "xtick.labelsize": 8, "ytick.labelsize": 8,
                             "axes.linewidth": 0.6, "xtick.direction": "out",
                             "ytick.direction": "out"})
        args.output_dir.mkdir(parents=True, exist_ok=True)
        print(f"Font: {font}")
        layouts = ("double", "single") if args.columns == "both" else (args.columns,)
        for path in paths:
            for columns in layouts:
                plot_dataset(path, args.output_dir, styles, args, columns)
    except (OSError, ValueError, KeyError, TypeError, csv.Error) as error:
        parser.exit(1, f"Cannot plot throughput: {error}\n")


if __name__ == "__main__":
    main()
