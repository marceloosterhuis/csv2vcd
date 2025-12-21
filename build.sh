#!/usr/bin/env bash
# Build script for csv2vcd on Unix-like systems (macOS, Linux); compiles with warnings enabled and O2
set -euo pipefail

CC="${CC:-cc}"                 # compiler (override with CC)
CFLAGS="-Wall -Wextra -O2 -std=c99" # strict warnings + O2
TARGET="csv2vcd"                # output binary

echo "Building $TARGET..."
$CC $CFLAGS csv2vcd.c -lm -o $TARGET

echo "Build successful: $TARGET"
echo "Run './$TARGET input.csv output.vcd' to use"
