#!/usr/bin/env pwsh
# PowerShell test harness for csv2vcd on Windows: builds with gcc, runs fixtures, strips $date, and diffs against goldens

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path) # repo root
$Bin = Join-Path $RepoRoot 'csv2vcd.exe'                                         # build output
$Tmp = New-TemporaryFile                                                         # temp VCD

function Cleanup {
    if (Test-Path $Tmp) { Remove-Item $Tmp -Force }
}
trap { Cleanup; throw }

Write-Host "Building csv2vcd.exe..."
if (-Not (Get-Command gcc -ErrorAction SilentlyContinue)) {
    Write-Error "gcc not found; install MinGW-w64 or adjust build step"
    Cleanup
    exit 1
}
& gcc -Wall -Wextra -O2 -std=c99 (Join-Path $RepoRoot 'csv2vcd.c') -lm -o $Bin

if ($LASTEXITCODE -ne 0) { Cleanup; exit $LASTEXITCODE }

function Strip-DateAndCompare {
    param(
        [string]$Csv,
        [string]$Expected
    )
    Write-Host "Running $Csv..."
    & $Bin $Csv $Tmp # run converter
    if ($LASTEXITCODE -ne 0) { Cleanup; exit $LASTEXITCODE }

    # Drop the first line ($date) before comparing
    $Actual = Get-Content $Tmp | Select-Object -Skip 1 # drop $date line
    $ExpectedLines = Get-Content $Expected
    if (-not ($Actual -eq $ExpectedLines)) {
        Write-Error "Mismatch for $Csv"
        Write-Host "--- Actual (no date) ---"
        $Actual | ForEach-Object { Write-Host $_ }
        Write-Host "--- Expected ---"
        $ExpectedLines | ForEach-Object { Write-Host $_ }
        Cleanup
        exit 1
    }
}

Strip-DateAndCompare (Join-Path $RepoRoot 'examples/simple.csv') (Join-Path $RepoRoot 'tests/fixtures/simple_expected.vcd')
Strip-DateAndCompare (Join-Path $RepoRoot 'examples/rounding.csv') (Join-Path $RepoRoot 'tests/fixtures/rounding_expected.vcd')

Write-Host "All tests passed."
Cleanup
