#!/usr/bin/env bash
# Build script for csv2vcd on Unix-like systems (macOS, Linux); compiles with warnings enabled and O2
set -euo pipefail

CC="${CC:-cc}"
CFLAGS="-Wall -Wextra -O2 -std=c99"
TARGET="csv2vcd"

echo "Building $TARGET..."
$CC $CFLAGS csv2vcd.c -lm -o $TARGET

echo "Build successful: $TARGET"
echo "Run './$TARGET input.csv output.vcd' to use"
