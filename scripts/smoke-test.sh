#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-dev}"

require_cmd timeout
src="$(chromium_src "$workspace")"
out_name="$(out_dir_name "$profile")"
chrome="$src/out/$out_name/chrome"

[[ -x "$chrome" ]] || fail "Chromium binary not found: $chrome"

info "Checking browser version"
"$chrome" --version

info "Running headless browser smoke test"
output="$(timeout 30 "$chrome" \
  --headless=new \
  --disable-gpu \
  --no-first-run \
  --no-default-browser-check \
  --dump-dom 'data:text/html,<p id="kitech-core-smoke">ok</p>' 2>&1)" || {
    printf '%s\n' "$output" >&2
    fail "headless Chromium smoke test failed"
  }

printf '%s\n' "$output" | grep -Fq 'kitech-core-smoke' || fail "headless smoke test did not return expected DOM"
info "Core Chromium smoke test passed"
