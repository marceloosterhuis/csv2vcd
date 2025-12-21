@echo off
REM Build script for csv2vcd on Windows
REM Requires MinGW-w64 or MSVC compiler

set TARGET=csv2vcd.exe
set CFLAGS=-Wall -Wextra -O2 -std=c99

echo Building %TARGET%...

REM Try gcc first (MinGW)
where gcc >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    gcc %CFLAGS% csv2vcd.c -lm -o %TARGET%
    if %ERRORLEVEL% EQU 0 (
        echo Build successful: %TARGET%
        echo Run '%TARGET% input.csv output.vcd' to use
        exit /b 0
    )
)

REM Try cl (MSVC)
where cl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    cl /W4 /O2 /Fe:%TARGET% csv2vcd.c
    if %ERRORLEVEL% EQU 0 (
        echo Build successful: %TARGET%
        echo Run '%TARGET% input.csv output.vcd' to use
        exit /b 0
    )
)

echo ERROR: No suitable C compiler found (gcc or cl)
echo Please install MinGW-w64 or Visual Studio Build Tools
exit /b 1
