#!/usr/bin/env python3
"""Regenerate and verify fixed tables and constants used by the equalizer kernels.

The script intentionally keeps the derivations separate from the AIE source so
the tables can be debugged on a normal Python installation.

Examples:
    python3 stage34/utils/replicate_frame_equalizer_constants.py
    python3 stage34/utils/replicate_frame_equalizer_constants.py --print
    python3 stage34/utils/replicate_frame_equalizer_constants.py \
        --source kernel/frame_equalizer_preprocess.cc \
        --source kernel/frame_equalizer_equalize.cc
"""

from __future__ import annotations

import argparse
import math
import re
import sys
from pathlib import Path


FFT_SIZE = 64
VECTOR_SIZE = 16
Q15 = 1 << 15


def extract_initializer(text: str, name: str) -> str:
    pattern = re.compile(
        rf"\b{re.escape(name)}\s*(?:\[[^\]]*\])?\s*=\s*\{{(?P<body>.*?)\}}\s*;",
        re.DOTALL,
    )
    match = pattern.search(text)
    if match is None:
        raise ValueError(f"could not find initializer for {name}")
    return match.group("body")


def parse_int_array(text: str, name: str) -> list[int]:
    body = extract_initializer(text, name)
    tokens = re.findall(r"(?<![A-Za-z_])-?(?:0[xX][0-9A-Fa-f]+|\d+)", body)
    return [int(token, 0) for token in tokens]


def parse_copy_array(text: str, name: str) -> list[tuple[int, int, int]]:
    body = extract_initializer(text, name)
    return [
        tuple(int(value) for value in match)
        for match in re.findall(
            r"\{\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\}", body
        )
    ]


def round_half_up(value: float) -> int:
    return math.floor(value + 0.5)


def parity(value: int) -> int:
    return value.bit_count() & 1


def expected_occupied() -> list[int]:
    return [int(6 <= bin_index <= 58 and bin_index != 32) for bin_index in range(FFT_SIZE)]


def expected_data_bins() -> list[int]:
    pilots = {11, 25, 39, 53}
    return [
        bin_index
        for bin_index in range(FFT_SIZE)
        if 6 <= bin_index <= 58 and bin_index != 32 and bin_index not in pilots
    ]


def expected_viterbi_parity(polynomial: int) -> list[int]:
    return [parity((state << 1) & polynomial) for state in range(64)]


def expected_overlap_mapping(
    source_length: int, copies: list[tuple[int, int, int]]
) -> list[int | None]:
    source = list(range(64)) + [0] * max(0, source_length - 64)
    destination: list[int | None] = [None] * 64
    for source_start, shift, destination_start in copies:
        load_end = source_start + 2 * VECTOR_SIZE
        if load_end > source_length:
            raise ValueError(
                f"overlap load [{source_start}, {load_end}) exceeds source length "
                f"{source_length}"
            )
        packed = (
            source[source_start + shift : source_start + VECTOR_SIZE]
            + source[source_start + VECTOR_SIZE : source_start + VECTOR_SIZE + shift]
        )
        destination[destination_start : destination_start + VECTOR_SIZE] = packed
    return destination


def expected_copy_tables() -> dict[str, list[tuple[int, int, int]]]:
    return {
        "kDataDecisionCopies": [
            (0, 6, 0),
            (0, 12, 5),
            (16, 10, 18),
            (32, 1, 24),
            (32, 8, 30),
            (48, 6, 43),
        ],
    }


def check_array(
    source_text: str,
    name: str,
    expected: list[int],
    failures: list[str],
) -> None:
    actual = parse_int_array(source_text, name)
    if actual == expected:
        print(f"PASS {name}: {len(expected)} values")
        return
    first_difference = next(
        (
            index
            for index, (actual_value, expected_value) in enumerate(zip(actual, expected))
            if actual_value != expected_value
        ),
        min(len(actual), len(expected)),
    )
    actual_value = actual[first_difference] if first_difference < len(actual) else "missing"
    expected_value = expected[first_difference] if first_difference < len(expected) else "missing"
    message = (
        f"FAIL {name}: index {first_difference}, got {actual_value}, "
        f"expected {expected_value}; lengths {len(actual)} != {len(expected)}"
    )
    print(message)
    failures.append(message)


def check_copies(
    source_text: str,
    name: str,
    expected: list[tuple[int, int, int]],
    failures: list[str],
) -> None:
    actual = parse_copy_array(source_text, name)
    if actual != expected:
        message = f"FAIL {name}: got {actual}, expected {expected}"
        print(message)
        failures.append(message)
        return

    source_length = 80 if name == "kDataDecisionCopies" else 64
    mapped = expected_overlap_mapping(source_length, actual)
    if name == "kDataDecisionCopies":
        expected_output = expected_data_bins()
    else:
        expected_output = [index for index, occupied in enumerate(expected_occupied()) if occupied]
    if mapped[: len(expected_output)] != expected_output:
        message = f"FAIL {name}: overlap mapping does not produce the expected carrier order"
        print(message)
        failures.append(message)
        return
    print(f"PASS {name}: table and overlap mapping")


def check_literal(
    source_text: str,
    label: str,
    literal: int,
    failures: list[str],
    expected_count: int = 1,
) -> None:
    count = len(re.findall(rf"(?<![A-Za-z_]){literal}(?![A-Za-z_])", source_text))
    if count == expected_count:
        print(f"PASS {label}: {literal}")
    else:
        message = f"FAIL {label}: literal {literal} occurs {count} times, expected {expected_count}"
        print(message)
        failures.append(message)


def check_definition(
    source_text: str,
    label: str,
    pattern: str,
    expected: str,
    failures: list[str],
) -> None:
    if re.search(pattern, source_text, re.DOTALL):
        print(f"PASS {label}: {expected}")
    else:
        message = f"FAIL {label}: expected definition {expected!r} is missing or changed"
        print(message)
        failures.append(message)


def check_rate_cases(source_text: str, failures: list[str]) -> None:
    expected = {
        11: (0, 2, 24),
        15: (1, 2, 36),
        10: (2, 4, 48),
        14: (3, 4, 72),
        9: (4, 16, 96),
        13: (5, 16, 144),
        8: (6, 64, 192),
        12: (7, 64, 216),
    }
    for rate, (encoding, modulation, n_dbps) in expected.items():
        pattern = (
            rf"case\s+{rate}:\s*d_encoding\s*=\s*{encoding};\s*"
            rf"d_modulation\s*=\s*{modulation};\s*n_dbps\s*=\s*{n_dbps};"
        )
        if re.search(pattern, source_text):
            print(f"PASS RATE {rate}: encoding={encoding}, modulation={modulation}, N_DBPS={n_dbps}")
        else:
            message = f"FAIL RATE {rate}: expected rate mapping is missing or changed"
            print(message)
            failures.append(message)


def format_values(values: list[int]) -> str:
    return ", ".join(str(value) for value in values)


def print_generated(reference_text: str) -> None:
    generated = {
        "kLong (standard reference)": parse_int_array(reference_text, "LONG"),
        "kPolarity (standard reference)": parse_int_array(reference_text, "POLARITY"),
        "kOccupied": expected_occupied(),
        "kDataCarrierBins": expected_data_bins(),
        "kViterbiParityA": expected_viterbi_parity(0o155),
        "kViterbiParityB": expected_viterbi_parity(0o117),
        "kViterbiStates": list(range(32)),
    }
    for name, values in generated.items():
        print(f"\n{name}[{len(values)}] = {{")
        for start in range(0, len(values), 16):
            print("    " + format_values(values[start : start + 16]) + ",")
        print("};")

    for name, copies in expected_copy_tables().items():
        print(f"\n{name} = {copies}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--source",
        type=Path,
        action="append",
        help="kernel source to verify; may be specified more than once",
    )
    parser.add_argument(
        "--reference",
        type=Path,
        default=Path(__file__).resolve().parents[2] / "stage34/original/equalizer/base.cc",
        help="reference source containing the standard LONG and POLARITY tables",
    )
    parser.add_argument(
        "--print",
        action="store_true",
        help="print regenerated tables after verification",
    )
    args = parser.parse_args()

    root = Path(__file__).resolve().parents[1]
    sources = args.source or [
        root / "kernel/frame_equalizer_preprocess.cc",
        root / "kernel/frame_equalizer_equalize.cc",
    ]
    source_text = "\n".join(source.read_text() for source in sources)
    reference_text = args.reference.read_text()
    failures: list[str] = []

    checks = [
        ("kLong", parse_int_array(reference_text, "LONG")),
        ("kPolarity", parse_int_array(reference_text, "POLARITY")),
        ("kOccupied", expected_occupied()),
        ("kPhaseLaneIndices", list(range(16))),
        ("kViterbiParityA", expected_viterbi_parity(0o155)),
        ("kViterbiParityB", expected_viterbi_parity(0o117)),
        ("kViterbiStates", list(range(32))),
    ]
    for name, expected in checks:
        check_array(source_text, name, expected, failures)

    for name, expected in expected_copy_tables().items():
        check_copies(source_text, name, expected, failures)

    qam_thresholds = {
        "QAM16 boundary": round_half_up(math.sqrt(2 / 5) * Q15),
        "QAM64 boundary 1": round_half_up(math.sqrt(2 / 21) * Q15),
        "QAM64 boundary 2": round_half_up(2 * math.sqrt(2 / 21) * Q15),
        "QAM64 boundary 3": round_half_up(3 * math.sqrt(2 / 21) * Q15),
    }
    for label, value in qam_thresholds.items():
        check_literal(source_text, label, value, failures)
    check_definition(source_text, "FFT size", r"#define\s+FFT_SIZE\s+64\b", "FFT_SIZE = 64", failures)
    check_definition(
        source_text,
        "OFDM symbol samples",
        r"#define\s+SAMPLES_WITH_CP\s+80\b",
        "SAMPLES_WITH_CP = 80",
        failures,
    )
    check_rate_cases(source_text, failures)

    if args.print:
        print_generated(reference_text)

    if failures:
        print(f"\n{len(failures)} verification failure(s)", file=sys.stderr)
        return 1
    print("\nAll frame_equalizer constant checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
