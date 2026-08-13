# Browser Core — Chromium

Private Chromium foundation and integration layer for the KiTech browser.

Authoritative architecture: [daijingroup/browser-spec](https://github.com/daijingroup/browser-spec).

## Role

This repository owns the neutral Chromium integration contract used by KiTech-controlled browser layers.

```text
Chromium
   ↓
browser-core-chromium
   ↓
browser-community-derived-chromium
   ↓
browser-kitech-derived-chromium
```

## Responsibilities

- pin the supported Chromium revision;
- define reproducible Chromium checkout and build orchestration;
- own neutral KiTech-authored Chromium integration patches;
- expose stable interfaces and extension points to upper layers;
- define common feature/build configuration;
- provide neutral packaging/update integration points;
- record critical build provenance.

## Current baseline

- Engine: Chromium
- Milestone: 151
- Tag: `151.0.7922.97`
- Revision: `dcfe8375afc319e40fec7cf87ce51feb3384bd5e`
- Core API: `1`
- Initial development host: Linux x86-64

The exact machine-readable pins live under `config/`.

## Dev machine quick start

On a Linux x86-64 development machine:

```bash
bash scripts/dev-machine-test.sh
```

This bootstraps the pinned toolchain/Chromium checkout, installs upstream Linux build dependencies, runs hooks, applies core patches, generates GN files, builds `chrome`, and performs a headless launch test.

See [docs/dev-machine.md](docs/dev-machine.md) for requirements, workspace options, and individual stages.

## Self-hosted full builds

A manual **Full Chromium Core Build** workflow targets a dedicated repository-scoped runner with these labels:

```text
self-hosted, linux, x64, chromium-builder
```

Runner setup is split into machine preparation and short-lived GitHub registration so the registration token is not consumed during the Chromium checkout.

See [docs/self-hosted-runner.md](docs/self-hosted-runner.md).

## Boundaries

This repository MUST NOT depend on:

- [`browser-community-derived-chromium`](https://github.com/daijingroup/browser-community-derived-chromium);
- [`browser-kitech-derived-chromium`](https://github.com/daijingroup/browser-kitech-derived-chromium).

Community-derived code such as Brave patches belongs in `browser-community-derived-chromium`.

KiTech product features such as Porticullus integration, browser sync, UI/product behaviour, enterprise features, and KiTech-specific services belong in `browser-kitech-derived-chromium`.

## Repository layout

```text
.github/        lightweight repository validation and manual full-build workflow
build/          build/workspace contract
config/         pinned upstream, API, patch and GN configuration
docs/           development, maintenance, runner and provenance documentation
interfaces/     contracts exposed to upper layers
patches/        neutral KiTech-authored Chromium patches
scripts/        bootstrap, runner, configure, build and smoke-test tooling
```

## Status

The core is ready for its first Linux x86-64 development-machine build test and for registration of a dedicated self-hosted Chromium builder. No neutral Chromium patches are currently required, so `config/patches.list` is intentionally empty.

This repository is private. No public licence grant is implied by access to its contents.
