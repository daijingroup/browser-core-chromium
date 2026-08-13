# Build Provenance

Every successful core build should emit a local `kitech-build-manifest.json` beside the build output.

The manifest records:

- `core_api` version;
- exact `browser-core-chromium` git revision;
- declared and actual Chromium revisions;
- Chromium milestone/tag;
- declared and actual `depot_tools` revisions;
- GN profile;
- build target;
- SHA-256 of the generated `args.gn`.

This allows a development build to be traced back to its critical source/tooling inputs.

## Scope

The local build manifest is provenance metadata, not a complete software bill of materials.

A production browser distribution must additionally generate a complete SBOM and third-party licence/notice set for Chromium and all selected upper-layer components during packaging/release. That work belongs to the distribution pipeline rather than the neutral core bootstrap.

## Location

Development:

```text
<workspace>/chromium/src/out/KiTechDev/kitech-build-manifest.json
```

Release-like validation:

```text
<workspace>/chromium/src/out/KiTechRelease/kitech-build-manifest.json
```
