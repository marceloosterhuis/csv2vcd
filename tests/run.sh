#!/usr/bin/env bash
# csv2vcd test harness (bash): builds the binary and diffs outputs against fixtures, skipping the date line
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" # repo root
BIN="$ROOT/csv2vcd"                                   # compiled binary path
TMP="$(mktemp)"                                       # temp output VCD
trap 'rm -f "$TMP"' EXIT

cc -Wall -Wextra -O2 "$ROOT/csv2vcd.c" -lm -o "$BIN" # build fresh binary

echo "Running simple.csv fixture..."
"$BIN" "$ROOT/examples/simple.csv" "$TMP"                      # run converter
tail -n +2 "$TMP" | diff -u "$ROOT/tests/fixtures/simple_expected.vcd" - # strip date, diff

echo "Running rounding.csv fixture..."
"$BIN" "$ROOT/examples/rounding.csv" "$TMP"
tail -n +2 "$TMP" | diff -u "$ROOT/tests/fixtures/rounding_expected.vcd" -

echo "All tests passed."
