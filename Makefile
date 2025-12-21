# Makefile for csv2vcd
# Cross-platform C project build system

# Compiler and flags
CC ?= cc
CFLAGS = -Wall -Wextra -O2 -std=c99
LDFLAGS = -lm

# Target executable
TARGET = csv2vcd
SRC = csv2vcd.c

# Platform detection
ifeq ($(OS),Windows_NT)
    TARGET := $(TARGET).exe
    RM = del /Q
    RMDIR = rmdir /S /Q
else
    RM = rm -f
    RMDIR = rm -rf
endif

# Default target builds the converter
all: $(TARGET)

# Build the executable
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(SRC) $(LDFLAGS) -o $(TARGET)

# Run tests (bash harness by default)
test: $(TARGET)
	@echo "Running tests..."
	@bash tests/run.sh

# Run tests via pytest. Ensures a uv-managed venv exists and pytest is installed.
pytest: $(TARGET)
	@echo "Ensuring uv virtual environment and pytest..."
	@if [ ! -d .venv ]; then uv venv .venv; fi
	uv pip install pytest
	@echo "Running pytest via uv (verbose)..."
	uv run pytest -vv

# Clean build artifacts
clean:
	$(RM) $(TARGET)

# Install to system (Unix-like systems only)
install: $(TARGET)
	@echo "Installing $(TARGET) to /usr/local/bin..."
	install -m 755 $(TARGET) /usr/local/bin/

# Uninstall from system
uninstall:
	@echo "Removing $(TARGET) from /usr/local/bin..."
	$(RM) /usr/local/bin/$(TARGET)

# Show help
help:
	@echo "csv2vcd Makefile targets:"
	@echo "  all       - Build the executable (default)"
	@echo "  test      - Build and run tests"
	@echo "  clean     - Remove build artifacts"
	@echo "  install   - Install to /usr/local/bin (Unix/macOS)"
	@echo "  uninstall - Remove from /usr/local/bin"
	@echo "  help      - Show this help message"

.PHONY: all test clean install uninstall help
