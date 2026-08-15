#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")/.." && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
ensure_workspace_path "$workspace"
check_linux_x86_64

chromium_dir="$(chromium_root "$workspace")"
depot="$(depot_tools_dir "$workspace")"

[[ "$workspace" != "/" ]] || fail "refusing to operate on root filesystem"
[[ "$chromium_dir" == "$workspace/chromium" ]] || fail "unexpected Chromium path: $chromium_dir"
[[ -d "$depot/.git" ]] || fail "pinned depot_tools checkout missing: $depot"

if [[ -d "$chromium_dir" ]]; then
  info "Removing existing Chromium checkout only: $chromium_dir"
  rm -rf --one-file-system "$chromium_dir"
fi

info "Recreating Chromium checkout in shallow/no-history mode at the pinned revision"
export KITECH_GCLIENT_VERBOSE=1
bash "$CORE_ROOT/scripts/bootstrap-linux.sh" "$workspace"

activate_depot_tools "$workspace"
(
  cd "$(chromium_root "$workspace")"
  gclient runhooks
)

bash "$CORE_ROOT/scripts/verify-pin.sh" "$workspace"

info "Shallow Chromium workspace ready"
df -h "$workspace"
du -sh "$workspace" "$chromium_dir" || true
