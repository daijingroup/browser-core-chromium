#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-dev}"
target="${3:-$(toml_value "$CORE_ROOT/config/core.toml" default_target)}"

activate_depot_tools "$workspace"
require_cmd autoninja
require_cmd python3

src="$(chromium_src "$workspace")"
out_name="$(out_dir_name "$profile")"
[[ -f "$src/out/$out_name/args.gn" ]] || fail "build is not configured; run configure.sh first"

jobs="${KITECH_BUILD_JOBS:-}"
build_args=(-C "out/$out_name")
if [[ -n "$jobs" ]]; then
  [[ "$jobs" =~ ^[1-9][0-9]*$ ]] || fail "KITECH_BUILD_JOBS must be a positive integer"
  build_args+=("-j$jobs")
fi
build_args+=("$target")

info "Building Chromium target '$target' with profile '$profile'${jobs:+ using $jobs parallel jobs}"
(
  cd "$src"
  autoninja "${build_args[@]}"
)

info "Writing build provenance manifest"
python3 "$CORE_ROOT/scripts/write-build-manifest.py" "$workspace" "$profile" "$target" >/dev/null

info "Build complete: $src/out/$out_name/$target"
