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
- define Chromium checkout and build orchestration;
- own neutral KiTech-authored Chromium integration patches;
- expose stable interfaces and extension points to upper layers;
- define common feature/build configuration;
- provide packaging and update integration points that are not product-specific.

## Boundaries

This repository MUST NOT depend on:

- [`browser-community-derived-chromium`](https://github.com/daijingroup/browser-community-derived-chromium);
- [`browser-kitech-derived-chromium`](https://github.com/daijingroup/browser-kitech-derived-chromium).

Community-derived code such as Brave patches belongs in `browser-community-derived-chromium`.

KiTech product features such as Porticullus integration, browser sync, UI/product behaviour, enterprise features, and KiTech-specific services belong in `browser-kitech-derived-chromium`.

## Repository layout

```text
build/          build and workspace contract
config/         engine/upstream configuration
interfaces/     contracts exposed to upper layers
patches/        neutral KiTech-authored Chromium patches
docs/           architecture and upstream maintenance notes
```

## Current status

Bootstrap stage. The repository structure and contracts are being established before a Chromium revision is pinned and build automation is implemented.

This repository is private. No public licence grant is implied by access to its contents.
