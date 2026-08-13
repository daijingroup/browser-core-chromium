# Core Chromium Patches

This directory is reserved for neutral KiTech-authored patches required by the Chromium foundation.

## Allowed

A patch belongs here when it is necessary to implement the engine integration contract and is not specific to a community-derived feature or KiTech product feature.

Examples:

- stable extension points needed by upper layers;
- neutral build hooks;
- neutral packaging/update hooks;
- minimal Chromium changes required to expose a core interface.

## Not allowed

The following do not belong here:

- Brave or other externally derived patches;
- modifications derived from community projects;
- Porticullus implementation;
- KiTech browser UI/product behaviour;
- KiTech sync implementation;
- enterprise or product-specific policy behaviour.

Externally derived patches belong in `browser-community-derived-chromium`. Product patches belong in `browser-kitech-derived-chromium`.

## Patch rules

Each patch MUST:

- have a narrow purpose;
- document why a Chromium patch is required;
- identify the Chromium revision against which it was validated;
- avoid unrelated formatting or refactoring;
- be removed when an upstream interface makes it unnecessary.

Patch ordering and application automation will be introduced when the first Chromium baseline is pinned.
