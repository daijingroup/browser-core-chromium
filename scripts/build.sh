#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-dev}"
target="${3:-$(toml_value "$CORE_ROOT/config/core.toml" default_target)}"

activate_depot_tools "$workspace"
require_cmd autoninja

src="$(chromium_src "$workspace")"
out_name="$(out_dir_name "$profile")"
[[ -f "$src/out/$out_name/args.gn" ]] || fail "build is not configured; run configure.sh first"

info "Building Chromium target '$target' with profile '$profile'"
(
  cd "$src"
  autoninja -C "out/$out_name" "$target"
)

info "Build complete: $src/out/$out_name/$target"
