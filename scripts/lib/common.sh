#!/usr/bin/env bash
set -euo pipefail

CORE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEFAULT_WORKSPACE="${KITECH_BROWSER_WORKSPACE:-${HOME}/kitech-browser-workspace}"

fail() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

info() {
  printf '==> %s\n' "$*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

toml_value() {
  local file="$1"
  local key="$2"
  python3 - "$file" "$key" <<'PY'
import pathlib
import sys
import tomllib

path = pathlib.Path(sys.argv[1])
key = sys.argv[2]
data = tomllib.loads(path.read_text(encoding="utf-8"))
value = data
for part in key.split("."):
    value = value[part]
if isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, list):
    print("\n".join(str(item) for item in value))
else:
    print(value)
PY
}

workspace_path() {
  printf '%s\n' "${1:-$DEFAULT_WORKSPACE}"
}

ensure_workspace_path() {
  local workspace="$1"
  [[ "$workspace" != *' '* ]] || fail "Chromium workspace path must not contain spaces: $workspace"
  mkdir -p "$workspace"
}

check_linux_x86_64() {
  [[ "$(uname -s)" == "Linux" ]] || fail "initial dev bootstrap currently supports Linux only"
  case "$(uname -m)" in
    x86_64|amd64) ;;
    *) fail "initial dev bootstrap currently supports x86-64 only" ;;
  esac
}

check_resources() {
  local workspace="$1"
  local available_kb
  local memory_kb
  available_kb="$(df -Pk "$workspace" | awk 'NR==2 {print $4}')"
  memory_kb="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"

  if (( available_kb < 100 * 1024 * 1024 )); then
    printf 'warning: Chromium recommends at least 100 GB free disk; detected about %d GB\n' "$((available_kb / 1024 / 1024))" >&2
  fi
  if (( memory_kb < 16 * 1024 * 1024 )); then
    printf 'warning: Chromium strongly benefits from more than 16 GB RAM; detected about %d GB\n' "$((memory_kb / 1024 / 1024))" >&2
  fi
}

chromium_revision() {
  toml_value "$CORE_ROOT/config/chromium.toml" revision
}

chromium_tag() {
  toml_value "$CORE_ROOT/config/chromium.toml" tag
}

chromium_source() {
  toml_value "$CORE_ROOT/config/chromium.toml" source
}

depot_tools_revision() {
  toml_value "$CORE_ROOT/config/depot_tools.toml" revision
}

depot_tools_source() {
  toml_value "$CORE_ROOT/config/depot_tools.toml" source
}

chromium_root() {
  printf '%s/chromium\n' "$1"
}

chromium_src() {
  printf '%s/chromium/src\n' "$1"
}

depot_tools_dir() {
  printf '%s/depot_tools\n' "$1"
}

activate_depot_tools() {
  local workspace="$1"
  local depot
  depot="$(depot_tools_dir "$workspace")"
  [[ -d "$depot/.git" ]] || fail "depot_tools is not bootstrapped: $depot"
  export DEPOT_TOOLS_UPDATE=0
  export PATH="$depot:$PATH"
}

profile_file() {
  local profile="$1"
  local file="$CORE_ROOT/config/gn/${profile}.gn"
  [[ -f "$file" ]] || fail "unknown GN profile: $profile"
  printf '%s\n' "$file"
}

out_dir_name() {
  case "$1" in
    dev) printf 'KiTechDev\n' ;;
    release) printf 'KiTechRelease\n' ;;
    *) fail "unknown GN profile: $1" ;;
  esac
}
