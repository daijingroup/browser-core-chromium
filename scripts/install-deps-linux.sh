#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
check_linux_x86_64
activate_depot_tools "$workspace"

src="$(chromium_src "$workspace")"
[[ -x "$src/build/install-build-deps.sh" ]] || fail "Chromium dependency installer not found; run bootstrap-linux.sh first"

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    printf 'warning: Chromium documents Ubuntu as its primary supported Linux development host; detected %s\n' "${PRETTY_NAME:-${ID:-unknown}}" >&2
  fi
fi

info "Installing Chromium Linux build dependencies"
(
  cd "$src"
  ./build/install-build-deps.sh
)

info "Running Chromium gclient hooks"
(
  cd "$(chromium_root "$workspace")"
  gclient runhooks
)

info "Chromium dependencies and hooks are ready"
