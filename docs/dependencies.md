# Dependency Policy

## Principle

`browser-core-chromium` keeps its dependency surface minimal and explicit.

## Upstream build inputs

The core currently has two primary external source inputs:

- Chromium, pinned in `config/chromium.toml`;
- `depot_tools`, pinned in `config/depot_tools.toml`.

Moving branches or tags must not replace the immutable revisions recorded in these manifests during a reproducible build.

## New dependencies

A new direct dependency must document:

- purpose;
- upstream project and repository;
- exact version or immutable revision where practical;
- licence;
- security/update owner;
- why Chromium or the standard toolchain cannot provide the capability.

Community-derived browser code does not belong in this repository. It belongs in `browser-community-derived-chromium` with its original provenance and licence obligations.

## Licensing

This private repository does not grant a public licence to KiTech-owned code.

Chromium, `depot_tools`, and their transitive components retain their upstream licences. Distribution packaging must preserve all required third-party notices and source/disclosure obligations.

## Updates

Chromium updates follow `browser-spec/03_release_and_upstream_policy.md`.

Tooling updates must be reviewed and pinned before use. Automatic `depot_tools` source updates are disabled by the core bootstrap so that toolchain changes are explicit.
