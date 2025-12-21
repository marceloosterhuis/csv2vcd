# csv2vcd

Convert CSV waveform data to Value Change Dump (VCD) format for use with digital waveform viewers and simulators.

## Overview

`csv2vcd` is a fast, lightweight C utility that transforms CSV files containing time-series signal data into IEEE 1364 VCD format. Optimized for large files with buffered I/O and efficient parsing.

## Features

- **Fast**: Optimized with large I/O buffers and in-place CSV parsing
- **Cross-platform**: Compiles on macOS, Linux, and Windows
- **Simple**: Single C file with no external dependencies
- **Smart**: Only emits VCD changes when signal values actually change
- **Precise**: Rounds values to 2 decimals for consistent change detection

## CSV Format Requirements

Your CSV must follow this structure:

1. **First row**: Header with signal names (column 0 is time, columns 1+ are signal names)
2. **Second row**: Initial values (seeds the VCD dump at time 0)
3. **Remaining rows**: Time-series data (time in seconds, signal values as floating-point)

### Example CSV

```csv
time,sig_a,sig_b
0.0,0.1,1.2
0.000000001,0.1,1.3
0.000000002,0.2,1.3
```

See [examples/](examples/) for more samples.

## Building

### macOS / Linux

```bash
# Using make
make

# Or using build script
chmod +x build.sh
./build.sh

# Or manually
cc -Wall -Wextra -O2 csv2vcd.c -lm -o csv2vcd
```

### Windows

```cmd
# Using build script
build.bat

# Or with MinGW
gcc -Wall -Wextra -O2 csv2vcd.c -lm -o csv2vcd.exe

# Or with MSVC
cl /W4 /O2 /Fe:csv2vcd.exe csv2vcd.c
```

## Usage

```bash
./csv2vcd input.csv output.vcd
```

The tool prints processing statistics:
```
Done, processed 4 rows. The elapsed time is 0.001 seconds.
```

## VCD Output

The generated VCD file uses:
- **Timescale**: 1ns (all CSV times must be in seconds)
- **Scope**: Single module named "dut"
- **Variables**: Real 64-bit values
- **Identifiers**: Single ASCII characters starting at '!' (supports up to 20 signals)

Only timestamps where signal values change are emitted to keep output compact.

## Limits

- **Max columns**: 20 (configurable via `MAX_COLS`)
- **Max cell size**: 50 characters (configurable via `MAXCHAR_COL`)
- **VCD identifiers**: Single ASCII chars (supports 20 signals)

## Testing

Run the test suite:

```bash
# Using make
make test

# Or directly
bash tests/run.sh
```

Tests validate against known fixtures with deterministic output (excluding the `$date` line).

## Installation

### Unix / macOS

```bash
sudo make install
# Installs to /usr/local/bin
```

To uninstall:
```bash
sudo make uninstall
```

### Windows

Copy `csv2vcd.exe` to a directory in your PATH.

## Performance Notes

- Uses 1MB I/O buffers for fast file processing
- In-place CSV parsing avoids string copies
- Cached constants reduce repeated math operations
- Change detection skips unchanged rows

## Technical Details

- **Rounding**: Values rounded to 2 decimals before comparison
- **Time conversion**: Seconds × 10⁹ → nanoseconds
- **Change detection**: Emits only when rounded values differ
- **Platform timing**: POSIX `gettimeofday` on Unix, Windows `GetSystemTimeAsFileTime` compatibility layer

## License

MIT License - see [LICENSE](LICENSE) file.

## Author

Marcel Oosterhuis

## Repository

https://github.com/marceloosterhuis/csv2vcd
