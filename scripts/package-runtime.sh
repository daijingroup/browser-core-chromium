#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

workspace="$(workspace_path "${1:-}")"
profile="${2:-release}"

src="$(chromium_src "$workspace")"
out_name="$(out_dir_name "$profile")"
out="$src/out/$out_name"

[[ -x "$out/chrome" ]] || fail "Chromium binary not found: $out/chrome"

milestone="$(toml_value "$CORE_ROOT/config/chromium.toml" milestone)"
tag="$(chromium_tag)"
artifact_root="$workspace/artifacts"
artifact_name="kitech-browser-core-chromium-m${milestone}-linux-x64"
stage="$artifact_root/$artifact_name"

rm -rf "$stage"
mkdir -p "$stage"

copy_required() {
  local name="$1"
  [[ -e "$out/$name" ]] || fail "required runtime file missing: $name"
  cp -a "$out/$name" "$stage/"
}

copy_optional() {
  local name="$1"
  [[ -e "$out/$name" ]] || return 0
  cp -a "$out/$name" "$stage/"
}

copy_required chrome
copy_required icudtl.dat
copy_required resources.pak

for name in \
  chrome_sandbox \
  chrome_100_percent.pak \
  chrome_200_percent.pak \
  snapshot_blob.bin \
  v8_context_snapshot.bin \
  vk_swiftshader_icd.json \
  libEGL.so \
  libGLESv2.so \
  libvk_swiftshader.so \
  chrome_crashpad_handler; do
  copy_optional "$name"
done

for dir in locales resources swiftshader MEIPreload; do
  copy_optional "$dir"
done

# Release builds are non-component, but some runtime support libraries may still
# be emitted at the top level. Include them without copying compilation output.
while IFS= read -r -d '' lib; do
  cp -a "$lib" "$stage/"
done < <(find "$out" -maxdepth 1 -type f \( -name '*.so' -o -name '*.so.*' \) -print0)

cat > "$stage/README.txt" <<EOF
KiTech Browser Core Chromium test runtime

Chromium milestone: $milestone
Chromium tag: $tag
Profile: $profile
Architecture: linux-x64

This is an unsigned development/test artifact, not a production browser release.
Run from this directory with:

  ./chrome --user-data-dir=./test-profile

If your distribution requires additional system libraries, install the equivalent
Chromium runtime dependencies from your package manager.
EOF

if [[ -f "$out/kitech-build-provenance.json" ]]; then
  cp -a "$out/kitech-build-provenance.json" "$stage/"
fi

size="$(du -sh "$stage" | awk '{print $1}')"
info "Runtime artifact staged: $stage ($size)"
printf '%s\n' "$stage"
