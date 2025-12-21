"""Pytest harness for csv2vcd: builds the binary, runs fixtures, strips $date, and compares to golden VCDs."""

import subprocess
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
BIN = REPO_ROOT / "csv2vcd"
TMP = REPO_ROOT / "tests" / "_tmp.vcd"

FIXTURES = [
    (REPO_ROOT / "examples" / "simple.csv", REPO_ROOT / "tests" / "fixtures" / "simple_expected.vcd"),
    (REPO_ROOT / "examples" / "rounding.csv", REPO_ROOT / "tests" / "fixtures" / "rounding_expected.vcd"),
]


def build_binary():
    """Compile csv2vcd with warnings enabled for test runs."""
    subprocess.run([
        "cc", "-Wall", "-Wextra", "-O2", "-std=c99",
        str(REPO_ROOT / "csv2vcd.c"), "-lm", "-o", str(BIN)
    ], check=True)


def strip_date(path: Path) -> list[str]:
    """Drop the first line ($date) to keep fixtures deterministic."""
    lines = path.read_text().splitlines()
    return lines[1:] if lines else []


def run_fixture(csv_path: Path, expected_path: Path):
    """Run csv2vcd on one CSV and compare against the golden VCD (minus date)."""
    subprocess.run([str(BIN), str(csv_path), str(TMP)], check=True)
    actual = strip_date(TMP)
    expected = expected_path.read_text().splitlines()
    assert actual == expected, f"Mismatch for {csv_path.name}"


def test_fixtures():
    """Execute all CSV fixtures end-to-end."""
    build_binary()
    for csv_path, expected_path in FIXTURES:
        run_fixture(csv_path, expected_path)


def teardown_module(module):
    if TMP.exists():
        TMP.unlink()
    if BIN.exists() and BIN.is_file():
        BIN.unlink()
