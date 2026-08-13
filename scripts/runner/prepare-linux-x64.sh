#!/usr/bin/env bash
set -euo pipefail

CORE_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RUNNER_USER="${RUNNER_USER:-github-runner}"
RUNNER_HOME="${RUNNER_HOME:-/var/lib/github-runner}"
BUILD_WORKSPACE="${KITECH_BROWSER_WORKSPACE:-/srv/kitech-browser-ci-workspace}"
SUDOERS_FILE="/etc/sudoers.d/kitech-browser-runner-bootstrap"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

[[ "$(uname -s)" == "Linux" ]] || fail "Linux is required"
[[ "$(uname -m)" == "x86_64" ]] || fail "x86_64 is required"
[[ "${EUID}" -eq 0 ]] || fail "run this preparation script as root"

if command -v apt-get >/dev/null 2>&1; then
  info "Installing host bootstrap packages"
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates curl git gzip python3 sudo tar util-linux
else
  fail "initial runner preparation currently supports apt-based Linux hosts only"
fi

if ! id "$RUNNER_USER" >/dev/null 2>&1; then
  info "Creating dedicated runner service account: $RUNNER_USER"
  useradd --system --create-home --home-dir "$RUNNER_HOME" --shell /bin/bash "$RUNNER_USER"
fi

RUNNER_GROUP="$(id -gn "$RUNNER_USER")"
install -d -o "$RUNNER_USER" -g "$RUNNER_GROUP" -m 0750 "$RUNNER_HOME"
install -d -o "$RUNNER_USER" -g "$RUNNER_GROUP" -m 0750 "$BUILD_WORKSPACE"

# The Chromium dependency installer expects to be run by a normal user and uses
# sudo for package installation. Grant temporary sudo only during this trusted,
# pinned bootstrap stage and remove it before any Actions runner service exists.
cleanup() {
  rm -f "$SUDOERS_FILE"
  if [[ -n "${TMP_CORE:-}" && -d "$TMP_CORE" ]]; then
    rm -rf "$TMP_CORE"
  fi
}
trap cleanup EXIT

printf '%s ALL=(ALL:ALL) NOPASSWD: ALL\n' "$RUNNER_USER" > "$SUDOERS_FILE"
chmod 0440 "$SUDOERS_FILE"
visudo -cf "$SUDOERS_FILE" >/dev/null

TMP_CORE="$(mktemp -d /tmp/kitech-browser-core-runner.XXXXXX)"
cp -a "$CORE_ROOT/." "$TMP_CORE/"
chown -R "$RUNNER_USER:$RUNNER_GROUP" "$TMP_CORE"

info "Bootstrapping the pinned Chromium/toolchain checkout"
runuser -u "$RUNNER_USER" -- env \
  HOME="$RUNNER_HOME" \
  bash "$TMP_CORE/scripts/bootstrap-linux.sh" "$BUILD_WORKSPACE"

info "Installing Chromium build dependencies and running hooks"
runuser -u "$RUNNER_USER" -- env \
  HOME="$RUNNER_HOME" \
  bash "$TMP_CORE/scripts/install-deps-linux.sh" "$BUILD_WORKSPACE"

info "Verifying the pinned Chromium revision"
runuser -u "$RUNNER_USER" -- env \
  HOME="$RUNNER_HOME" \
  bash "$TMP_CORE/scripts/verify-pin.sh" "$BUILD_WORKSPACE"

# Remove temporary privilege before returning. The registered Actions runner
# account must not have passwordless sudo access.
rm -f "$SUDOERS_FILE"

info "Runner host preparation complete"
info "Persistent Chromium workspace: $BUILD_WORKSPACE"
info "Next: obtain a repository runner registration token and run scripts/runner/register-linux-x64.sh"
