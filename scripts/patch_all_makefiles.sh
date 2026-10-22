#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "==> Patching all Makefiles across workspace for BSC 2024.07 compatibility..."

# Fix GHC RTS integer overflow (-K40000M -> -K4000M) and remove obsolete verilog-filter
find "${WORKSPACE_ROOT}" -type f -name "Makefile*" 2>/dev/null | while read -r mkfile; do
    if grep -q -- "-K40000M" "$mkfile" 2>/dev/null; then
        echo "--> Fixing -K40000M in: $mkfile"
        sed -i 's/-K40000M/-K4000M/g' "$mkfile"
    fi
    if grep -q -- "-verilog-filter" "$mkfile" 2>/dev/null; then
        echo "--> Removing -verilog-filter in: $mkfile"
        sed -i 's|-verilog-filter [^ ]*||g' "$mkfile"
    fi
done

echo "==> All Makefiles successfully patched!"
