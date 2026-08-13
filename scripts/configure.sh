#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-dev}"

activate_depot_tools "$workspace"
require_cmd gn

src="$(chromium_src "$workspace")"
[[ -d "$src/.git" ]] || fail "Chromium checkout not found: $src"
bash "$CORE_ROOT/scripts/verify-pin.sh" "$workspace"

preset="$(profile_file "$profile")"
out_name="$(out_dir_name "$profile")"
out_path="$src/out/$out_name"
mkdir -p "$out_path"
cp "$preset" "$out_path/args.gn"

info "Generating Chromium build files with profile '$profile'"
(
  cd "$src"
  gn gen "out/$out_name"
)

info "GN configuration ready: $out_path"
