# Build Contract

`browser-core-chromium` defines how a supported Chromium source tree is prepared for the KiTech browser stack.

## Workspace model

The development tooling creates an external workspace containing:

```text
workspace/
├── depot_tools/
└── chromium/
    └── src/
        └── out/
            ├── KiTechDev/
            └── KiTechRelease/
```

The KiTech core repository remains separate from the large Chromium checkout.

## Layer application order

```text
Chromium checkout
   ↓
browser-core-chromium
   ↓
browser-community-derived-chromium
   ↓
browser-kitech-derived-chromium
   ↓
GN / autoninja build
```

A core-only build MUST remain possible without either upper layer.

## Implemented core build flow

```text
bootstrap-linux.sh
      ↓
install-deps-linux.sh
      ↓
verify-pin.sh
      ↓
apply-patches.sh
      ↓
configure.sh
      ↓
build.sh
      ↓
smoke-test.sh
```

`dev-machine-test.sh` executes the complete flow for the initial Linux x86-64 development host.

## Profiles

- `dev` → `out/KiTechDev`, component build intended to reduce local link cost while retaining DCHECK coverage.
- `release` → `out/KiTechRelease`, non-component release-like validation build. It is not the final signed production configuration.

GN arguments are versioned under `config/gn/` and copied into the selected output directory before `gn gen`.

## CI

Normal GitHub-hosted runners validate manifests and shell syntax.

Full Chromium builds should run only on infrastructure with sufficient CPU, memory, disk, and persistent caching, such as an appropriately sized larger runner or self-hosted runner.

## Reproducibility

Build tooling MUST NOT silently select a newer Chromium revision than `config/chromium.toml`.

`depot_tools` is also pinned and its source auto-update is disabled by the core bootstrap. Every successful build writes `kitech-build-manifest.json` containing the critical declared and actual source/tool revisions plus the GN configuration hash.

See:

- `docs/dev-machine.md`
- `docs/upstream.md`
- `docs/provenance.md`
