# Chromium Upstream Policy

## Source

Canonical Chromium source:

`https://chromium.googlesource.com/chromium/src.git`

The selected upstream revision is recorded in `config/chromium.toml`.

## Pinning

A supported Chromium baseline MUST use an exact immutable revision.

When selecting or updating a baseline:

1. choose the target Chromium milestone/revision;
2. update `config/chromium.toml`;
3. verify all neutral core patches apply cleanly;
4. verify upper-layer integration contracts remain valid;
5. run the supported build and test matrix;
6. record required migration notes with the change.

Branches such as `main`, `stable`, or other moving refs MUST NOT be used as release pins.

## Checkout model

Chromium source should be acquired into a build workspace rather than committed into this repository.

This repository should contain only the KiTech-owned integration material needed to reproduce the supported Chromium baseline.

## Rebase policy

Core Chromium changes SHOULD be kept small and isolated. Prefer extension points and explicit interfaces over patches where Chromium already provides a suitable mechanism.

If an upstream Chromium update breaks a patch, the patch must be reviewed rather than blindly regenerated.

## Dependency boundary

Upstream maintenance in this repository must not introduce dependencies on either sibling upper layer:

- `browser-community-derived-chromium`
- `browser-kitech-derived-chromium`
