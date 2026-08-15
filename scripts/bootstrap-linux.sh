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
source_url="$(chromium_source)"
revision="$(chromium_revision)"
tag="$(chromium_tag)"

mkdir -p "$chromium_root_path"

# The Chromium solution itself is pinned by Git. gclient is configured as
# unmanaged so it synchronises DEPS without attempting a second root fetch.
if [[ ! -d "$chromium_src_path/.git" ]]; then
  if [[ -e "$chromium_src_path" ]]; then
    fail "Chromium source path exists but is not a git checkout: $chromium_src_path"
  fi
  info "Initialising shallow Chromium root checkout"
  git init "$chromium_src_path"
  git -C "$chromium_src_path" remote add origin "$source_url"
else
  git -C "$chromium_src_path" remote set-url origin "$source_url"
fi

if ! git -C "$chromium_src_path" cat-file -e "$revision^{commit}" 2>/dev/null; then
  info "Fetching Chromium $tag as a shallow root checkout"
  git -C "$chromium_src_path" fetch \
    --progress \
    --depth=1 \
    --no-tags \
    origin "refs/tags/$tag"

  fetched_revision="$(git -C "$chromium_src_path" rev-parse 'FETCH_HEAD^{commit}')"
  [[ "$fetched_revision" == "$revision" ]] || \
    fail "Chromium tag $tag resolved to $fetched_revision; expected $revision"
fi

info "Checking out immutable Chromium revision $revision"
git -C "$chromium_src_path" checkout --detach --force "$revision"
git -C "$chromium_src_path" reset --hard "$revision"

info "Configuring gclient to leave the pinned Chromium root unmanaged"
rm -f "$chromium_root_path/.gclient"
(
  cd "$chromium_root_path"
  gclient config --name src --unmanaged "$source_url"
)

info "Synchronising Chromium $tag dependencies without full git history"
gclient_args=(
  sync
  --no-history
  --nohooks
  --force
  --delete_unversioned_trees
)
if [[ "${KITECH_GCLIENT_VERBOSE:-0}" == "1" ]]; then
  gclient_args+=(--verbose)
fi
(
  cd "$chromium_root_path"
  gclient "${gclient_args[@]}"
)

[[ -d "$chromium_src_path/.git" ]] || fail "Chromium source checkout was not created"
actual="$(git -C "$chromium_src_path" rev-parse HEAD)"
[[ "$actual" == "$revision" ]] || fail "Chromium revision mismatch: expected $revision, got $actual"

info "Chromium source is pinned and ready for dependency installation/hooks"
printf 'workspace: %s\nchromium: %s\nrevision: %s\n' "$workspace" "$tag" "$actual"
