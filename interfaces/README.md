# Core Interfaces

This directory defines contracts exposed by `browser-core-chromium` to upper layers.

The core must expose capabilities without depending on their implementations.

## Compatibility version

The machine-readable interface compatibility version is `core_api` in `config/core.toml`.

Upper layers SHOULD declare the `core_api` versions they support. An incompatible API version must fail integration rather than silently continuing with undefined behaviour.

The initial compatibility version is:

```text
core_api = 1
```

## Initial interface areas

### Identity provider

Provides a neutral browser identity integration point.

The Porticullus implementation belongs in `browser-kitech-derived-chromium`, not here.

Expected responsibilities include:

- sign-in/session state;
- account/profile identity;
- trusted-device registration hooks;
- authentication event propagation.

### Sync provider

Provides a neutral browser sync integration point.

The KiTech sync implementation and encryption policy belong in `browser-kitech-derived-chromium` and the authoritative browser specification.

Expected responsibilities include:

- sync capability registration;
- profile sync lifecycle hooks;
- local change notifications;
- remote update application hooks;
- encrypted payload transport boundaries.

### Policy provider

Provides hooks for browser-level managed policy without coupling the core to a specific KiTech enterprise service.

### Update integration

Provides neutral hooks for browser packaging/update orchestration without embedding a product-specific service implementation.

## Rules

- interfaces MUST remain implementation-neutral;
- upper layers MAY depend on these contracts;
- the core MUST NOT import upper-layer implementations;
- `core_api` MUST change when compatibility can no longer be maintained;
- security-sensitive boundaries MUST fail closed when an implementation is unavailable or incompatible.

Concrete C++/Rust/interface definitions will be added only when the first Chromium integration point requires them. The compatibility contract is versioned now so upper-layer work does not depend on undocumented assumptions.
