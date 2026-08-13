#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"

info "Bootstrapping pinned Chromium workspace"
bash "$CORE_ROOT/scripts/bootstrap-linux.sh" "$workspace"

if [[ "${KITECH_SKIP_DEPS:-0}" != "1" ]]; then
  info "Installing build dependencies and running Chromium hooks"
  bash "$CORE_ROOT/scripts/install-deps-linux.sh" "$workspace"
else
  info "Skipping dependency installation because KITECH_SKIP_DEPS=1"
  activate_depot_tools "$workspace"
  (
    cd "$(chromium_root "$workspace")"
    gclient runhooks
  )
fi

bash "$CORE_ROOT/scripts/apply-patches.sh" "$workspace"
bash "$CORE_ROOT/scripts/configure.sh" "$workspace" dev
bash "$CORE_ROOT/scripts/build.sh" "$workspace" dev chrome
bash "$CORE_ROOT/scripts/smoke-test.sh" "$workspace" dev

info "Dev-machine core test completed successfully"
