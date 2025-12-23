"""Pytest harness for csv2vcd: builds the binary, runs fixtures, strips $date, and compares to golden VCDs."""

import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
BIN = REPO_ROOT / "csv2vcd"
TMP = REPO_ROOT / "tests" / "_tmp.vcd"

FIXTURES = [
    (REPO_ROOT / "examples" / "simple.csv", REPO_ROOT / "tests" / "fixtures" / "simple_expected.vcd"),
    (REPO_ROOT / "examples" / "rounding.csv", REPO_ROOT / "tests" / "fixtures" / "rounding_expected.vcd"),
]
FIXTURE_IDS = [csv_path.stem for csv_path, _ in FIXTURES]


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


@pytest.fixture(scope="session", autouse=True)
def build_once():
    """Build the binary once per test session to keep runs fast.
    
    @pytest.fixture marks this as a pytest fixture; scope='session' means it runs once
    per test session (not per test); autouse=True means pytest calls it automatically
    without the test needing to request it as a parameter.
    """
    build_binary()
    yield
    if BIN.exists() and BIN.is_file():
        BIN.unlink()


@pytest.mark.parametrize("csv_path, expected_path", FIXTURES, ids=FIXTURE_IDS)
def test_fixtures(csv_path: Path, expected_path: Path):
    """Execute each CSV fixture end-to-end; IDs show which fixture is running.
    
    @pytest.mark.parametrize creates one test case per item in FIXTURES, passing
    each CSV and expected VCD pair as arguments. ids=FIXTURE_IDS labels each test
    with the CSV filename (e.g. 'simple', 'rounding') for readable output.
    """
    run_fixture(csv_path, expected_path)


def teardown_module(module):
    """Pytest hook invoked automatically after all tests in this module complete.
    
    Pytest recognizes 'teardown_module' by name and calls it once per module to
    clean up resources. Here we remove the temporary VCD and compiled binary.
    """
    if TMP.exists():
        TMP.unlink()
    if BIN.exists() and BIN.is_file():
        BIN.unlink()
