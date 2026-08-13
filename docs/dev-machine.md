# Dev Machine Test

The first supported development host is Linux x86-64.

## Host requirements

KiTech tooling requires:

- Linux x86-64;
- Git;
- Python 3.11+;
- a workspace path with no spaces.

Chromium recommends at least 100 GB of free disk space and benefits substantially from more than 16 GB of RAM. The bootstrap script reports warnings when the detected machine is below those values.

Chromium documents Ubuntu as its primary Linux development environment. Other Linux distributions may work, but upstream dependency installation can require distro-specific handling.

## One-command test

From a clone of this repository:

```bash
bash scripts/dev-machine-test.sh
```

The default workspace is:

```text
$HOME/kitech-browser-workspace
```

To use a different workspace:

```bash
bash scripts/dev-machine-test.sh /path/without/spaces
```

The first run performs the following stages:

1. clones and pins `depot_tools`;
2. creates the Chromium checkout;
3. synchronises the exact Chromium revision declared in `config/chromium.toml`;
4. runs Chromium's Linux dependency installer and `gclient` hooks;
5. verifies the Chromium pin;
6. applies the ordered neutral core patch set;
7. generates the `dev` GN build;
8. builds the `chrome` target with `autoninja`;
9. launches a headless Chromium smoke test.

Chromium's dependency installer may request `sudo` access on supported package-based Linux hosts.

## Existing dependencies

If Chromium build dependencies are already installed, skip the dependency installer while still running hooks:

```bash
KITECH_SKIP_DEPS=1 bash scripts/dev-machine-test.sh
```

## Manual stages

Each stage can be run separately:

```bash
bash scripts/bootstrap-linux.sh
bash scripts/install-deps-linux.sh
bash scripts/verify-pin.sh
bash scripts/apply-patches.sh
bash scripts/configure.sh "$HOME/kitech-browser-workspace" dev
bash scripts/build.sh "$HOME/kitech-browser-workspace" dev chrome
bash scripts/smoke-test.sh "$HOME/kitech-browser-workspace" dev
```

## Build outputs

Development build:

```text
$HOME/kitech-browser-workspace/chromium/src/out/KiTechDev/
```

Release-like validation build:

```bash
bash scripts/configure.sh "$HOME/kitech-browser-workspace" release
bash scripts/build.sh "$HOME/kitech-browser-workspace" release chrome
```

Output:

```text
$HOME/kitech-browser-workspace/chromium/src/out/KiTechRelease/
```

The release profile is for local integration validation. It is not a signed production release configuration.

## Safety

The bootstrap does not silently discard local Chromium source changes. If an existing checkout has conflicting modifications, use a fresh workspace or explicitly reconcile/reset those changes before retrying.

No Google API keys, KiTech service credentials, signing keys, or user data are required to build and smoke-test the core.
