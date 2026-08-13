#!/usr/bin/env bash
set -euo pipefail

RUNNER_USER="${RUNNER_USER:-github-runner}"
RUNNER_HOME="${RUNNER_HOME:-/var/lib/github-runner}"
RUNNER_DIR="${RUNNER_DIR:-/opt/github-actions-runner/browser-core-chromium}"
BUILD_WORKSPACE="${KITECH_BROWSER_WORKSPACE:-/srv/kitech-browser-ci-workspace}"
RUNNER_VERSION="${RUNNER_VERSION:-2.336.0}"
RUNNER_NAME="${RUNNER_NAME:-$(hostname -s)-chromium}"
RUNNER_LABELS="${RUNNER_LABELS:-chromium-builder}"
REPOSITORY_URL="https://github.com/daijingroup/browser-core-chromium"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

[[ "$(uname -s)" == "Linux" ]] || fail "Linux is required"
[[ "$(uname -m)" == "x86_64" ]] || fail "x86_64 is required"
[[ "${EUID}" -eq 0 ]] || fail "run this registration script as root"

: "${RUNNER_TOKEN:?Set RUNNER_TOKEN to the short-lived repository runner registration token}"
: "${RUNNER_SHA256:?Set RUNNER_SHA256 to the SHA-256 shown by GitHub for the Linux x64 runner package}"

id "$RUNNER_USER" >/dev/null 2>&1 || fail "runner user does not exist; run prepare-linux-x64.sh first"
[[ -d "$BUILD_WORKSPACE/chromium/src/.git" ]] || fail "prepared Chromium workspace not found; run prepare-linux-x64.sh first"

RUNNER_GROUP="$(id -gn "$RUNNER_USER")"
install -d -o "$RUNNER_USER" -g "$RUNNER_GROUP" -m 0750 "$(dirname "$RUNNER_DIR")"

if [[ -e "$RUNNER_DIR/.runner" ]]; then
  fail "a runner is already configured at $RUNNER_DIR"
fi

rm -rf "$RUNNER_DIR"
install -d -o "$RUNNER_USER" -g "$RUNNER_GROUP" -m 0750 "$RUNNER_DIR"

archive="actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz"
url="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${archive}"

info "Downloading GitHub Actions runner v${RUNNER_VERSION}"
curl --fail --location --proto '=https' --tlsv1.2 \
  --output "$RUNNER_DIR/$archive" "$url"

printf '%s  %s\n' "$RUNNER_SHA256" "$RUNNER_DIR/$archive" | sha256sum --check --status \
  || fail "runner package SHA-256 verification failed"

info "Runner package checksum verified"
tar -xzf "$RUNNER_DIR/$archive" -C "$RUNNER_DIR"
rm -f "$RUNNER_DIR/$archive"
chown -R "$RUNNER_USER:$RUNNER_GROUP" "$RUNNER_DIR"

if [[ -x "$RUNNER_DIR/bin/installdependencies.sh" ]]; then
  info "Installing GitHub Actions runner runtime dependencies"
  "$RUNNER_DIR/bin/installdependencies.sh"
fi

info "Registering repository-scoped runner: $RUNNER_NAME"
runuser -u "$RUNNER_USER" -- env HOME="$RUNNER_HOME" \
  "$RUNNER_DIR/config.sh" \
    --unattended \
    --url "$REPOSITORY_URL" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work _work \
    --replace

# Runner services read variables from .env in the application directory.
# Keep the Chromium checkout outside the Actions job work directory so it can be
# reused safely between manually dispatched full builds.
printf 'KITECH_BROWSER_WORKSPACE=%s\n' "$BUILD_WORKSPACE" >> "$RUNNER_DIR/.env"
chown "$RUNNER_USER:$RUNNER_GROUP" "$RUNNER_DIR/.env"
chmod 0640 "$RUNNER_DIR/.env"

info "Installing runner as a system service"
(
  cd "$RUNNER_DIR"
  ./svc.sh install "$RUNNER_USER"
  ./svc.sh start
  ./svc.sh status
)

info "Self-hosted Chromium builder registered"
info "Expected labels: self-hosted, linux, x64, $RUNNER_LABELS"
