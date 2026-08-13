# Build Contract

`browser-core-chromium` defines how a supported Chromium source tree is prepared for the KiTech browser stack.

## Workspace model

Build tooling should create an external workspace containing:

```text
workspace/
├── depot_tools/
├── chromium/
│   └── src/
├── core/
├── community-derived/
├── kitech-derived/
└── out/
```

Only `core/` is sourced from this repository.

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
GN/Ninja build
```

A core-only build MUST remain possible without either upper layer.

## CI

Normal GitHub-hosted runners may be used for lightweight validation such as manifest checks, formatting, patch metadata checks, and small unit tests.

Full Chromium builds should run only on infrastructure with sufficient CPU, memory, and persistent storage, such as an appropriately sized larger runner or self-hosted runner.

## Reproducibility

Build inputs MUST be explicit and pinned where practical. Build tooling MUST NOT silently select a newer Chromium revision than the one declared by `config/chromium.toml`.

Actual checkout/build scripts will be added once the initial Chromium revision and supported development platform are selected.
