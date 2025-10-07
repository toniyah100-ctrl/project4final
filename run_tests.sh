#!/usr/bin/env bash
set -euo pipefail
BIN=./comp430
TEST_DIR=tests
OUT_DIR=outputs

[[ -x "$BIN" ]] || { echo "❌ $BIN not built. Run: make"; exit 1; }
[[ -d "$TEST_DIR" ]] || { echo "❌ No tests directory ($TEST_DIR)"; exit 1; }

mkdir -p "$OUT_DIR"

shopt -s nullglob
files=("$TEST_DIR"/*.txt)
if (( ${#files[@]} == 0 )); then
  echo "❌ No .txt files found in $TEST_DIR"
  exit 1
fi

for f in "${files[@]}"; do
  base="$(basename "$f" .txt)"
  echo "===== $f ====="
  "$BIN" < "$f" | tee "${OUT_DIR}/${base}.out"
  echo
done

echo "✅ Done. Outputs saved in '${OUT_DIR}/'."
