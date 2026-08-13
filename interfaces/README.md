# Core Interfaces

This directory defines contracts exposed by `browser-core-chromium` to upper layers.

The core must expose capabilities without depending on their implementations.

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
- interfaces SHOULD be versioned when compatibility can no longer be maintained;
- security-sensitive boundaries MUST fail closed when an implementation is unavailable or incompatible.

Concrete interface definitions will be added alongside the first working Chromium integration rather than invented ahead of the implementation language and Chromium embedding points.
