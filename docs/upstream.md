# Chromium Upstream Policy

## Sources

Canonical Chromium source:

`https://chromium.googlesource.com/chromium/src.git`

Canonical Chromium build tooling source:

`https://chromium.googlesource.com/chromium/tools/depot_tools.git`

The selected immutable revisions are recorded in:

- `config/chromium.toml`;
- `config/depot_tools.toml`.

## Current baseline

Chromium milestone 151 is the initial baseline:

- tag: `151.0.7922.97`;
- revision: `dcfe8375afc319e40fec7cf87ce51feb3384bd5e`.

The release/promotion policy is authoritative in `daijingroup/browser-spec`.

## Pinning

A supported Chromium baseline MUST use an exact immutable revision.

When selecting or updating a baseline:

1. choose a Chromium Stable milestone/revision;
2. update `config/chromium.toml`;
3. verify all neutral core patches apply cleanly;
4. verify upper-layer integration contracts remain valid;
5. run the supported build and test matrix;
6. record required migration notes with the change.

Branches such as `main`, `stable`, or other moving refs MUST NOT be used as release pins.

`depot_tools` is also pinned. The bootstrap sets `DEPOT_TOOLS_UPDATE=0` so a development build does not silently change tool source revisions.

## Checkout model

Chromium source and `depot_tools` are acquired into an external build workspace rather than committed into this repository.

The bootstrap uses `gclient sync --revision src@<revision>` and verifies the resulting Chromium `HEAD` against the declared pin.

This repository contains only the KiTech-owned neutral integration material required to reproduce the supported Chromium baseline.

## Rebase policy

Core Chromium changes SHOULD remain small and isolated. Prefer extension points and explicit interfaces over patches where Chromium already provides a suitable mechanism.

If an upstream Chromium update breaks a patch, the patch must be reviewed rather than blindly regenerated.

Security-patched revisions within the accepted stable milestone may be advanced under the browser-spec security policy. New milestones must pass the KiTech unstable/testing/stable promotion process.

## Dependency boundary

Upstream maintenance in this repository must not introduce dependencies on either sibling upper layer:

- `browser-community-derived-chromium`;
- `browser-kitech-derived-chromium`.
