#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
src="$(chromium_src "$workspace")"
manifest="$CORE_ROOT/config/patches.list"

[[ -d "$src/.git" ]] || fail "Chromium checkout not found: $src"
"$CORE_ROOT/scripts/verify-pin.sh" "$workspace"

count=0
while IFS= read -r entry || [[ -n "$entry" ]]; do
  entry="${entry%%#*}"
  entry="$(printf '%s' "$entry" | xargs)"
  [[ -n "$entry" ]] || continue

  patch="$CORE_ROOT/$entry"
  [[ -f "$patch" ]] || fail "patch listed in manifest does not exist: $entry"

  if git -C "$src" apply --reverse --check "$patch" >/dev/null 2>&1; then
    info "Patch already applied: $entry"
    ((count += 1))
    continue
  fi

  git -C "$src" apply --check "$patch" || fail "patch no longer applies cleanly: $entry"
  info "Applying patch: $entry"
  git -C "$src" apply "$patch"
  ((count += 1))
done < "$manifest"

info "Core patch stage complete ($count patch(es))"
