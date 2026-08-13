#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
src="$(chromium_src "$workspace")"
expected="$(chromium_revision)"
expected_tag="$(chromium_tag)"

[[ -d "$src/.git" ]] || fail "Chromium checkout not found: $src"
actual="$(git -C "$src" rev-parse HEAD)"
[[ "$actual" == "$expected" ]] || fail "Chromium revision mismatch: expected $expected, got $actual"

if git -C "$src" tag --points-at HEAD | grep -Fxq "$expected_tag"; then
  info "Chromium pin verified: $expected_tag ($actual)"
else
  info "Chromium revision verified: $actual (tag metadata not present locally)"
fi
