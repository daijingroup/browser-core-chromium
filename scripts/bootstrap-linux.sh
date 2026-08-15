#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"

check_linux_x86_64
require_cmd git
require_cmd python3
python3 -c 'import tomllib' >/dev/null 2>&1 || fail "Python 3.11+ is required by the KiTech bootstrap tooling"

ensure_workspace_path "$workspace"
check_resources "$workspace"

depot="$(depot_tools_dir "$workspace")"
depot_source="$(depot_tools_source)"
depot_revision="$(depot_tools_revision)"

if [[ ! -d "$depot/.git" ]]; then
  info "Cloning pinned depot_tools source"
  git clone "$depot_source" "$depot"
fi

[[ -z "$(git -C "$depot" status --porcelain)" ]] || fail "depot_tools checkout has local changes: $depot"
info "Pinning depot_tools to $depot_revision"
git -C "$depot" fetch origin "$depot_revision"
git -C "$depot" checkout --detach "$depot_revision"

activate_depot_tools "$workspace"
info "Bootstrapping pinned depot_tools runtime"
"$depot/ensure_bootstrap"
gclient --version >/dev/null

chromium_root_path="$(chromium_root "$workspace")"
chromium_src_path="$(chromium_src "$workspace")"
revision="$(chromium_revision)"
tag="$(chromium_tag)"

mkdir -p "$chromium_root_path"
if [[ ! -f "$chromium_root_path/.gclient" ]]; then
  if [[ -n "$(find "$chromium_root_path" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
    fail "Chromium workspace exists but is not a gclient checkout: $chromium_root_path"
  fi
  info "Creating shallow Chromium checkout"
  (
    cd "$chromium_root_path"
    fetch --no-history --nohooks chromium
  )
fi

info "Synchronising Chromium $tag at immutable revision $revision without full git history"
(
  cd "$chromium_root_path"
  gclient sync \
    --no-history \
    --nohooks \
    --force \
    --delete_unversioned_trees \
    --revision "src@$revision"
)

[[ -d "$chromium_src_path/.git" ]] || fail "Chromium source checkout was not created"
actual="$(git -C "$chromium_src_path" rev-parse HEAD)"
[[ "$actual" == "$revision" ]] || fail "Chromium revision mismatch: expected $revision, got $actual"

info "Chromium source is pinned and ready for dependency installation/hooks"
printf 'workspace: %s\nchromium: %s\nrevision: %s\n' "$workspace" "$tag" "$actual"
