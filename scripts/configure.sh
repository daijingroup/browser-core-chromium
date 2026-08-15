#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-dev}"

src="$(chromium_src "$workspace")"
[[ -d "$src/.git" ]] || fail "Chromium checkout not found: $src"
bash "$CORE_ROOT/scripts/verify-pin.sh" "$workspace"

preset="$(profile_file "$profile")"
out_name="$(out_dir_name "$profile")"
out_path="$src/out/$out_name"
gn_bin="$src/buildtools/linux64/gn"

[[ -x "$gn_bin" ]] || fail "Chromium-pinned GN binary not found: $gn_bin; run gclient hooks first"

mkdir -p "$out_path"
cp "$preset" "$out_path/args.gn"

info "Generating Chromium build files with profile '$profile'"
(
  cd "$src"
  "$gn_bin" gen "out/$out_name"
)

info "GN configuration ready: $out_path"
