# Self-Hosted Chromium Builder

`browser-core-chromium` uses a dedicated repository-scoped GitHub Actions runner for full Chromium builds.

## Security model

The runner is intended only for this private repository.

Do not install it on a production application server, identity server, secrets host, or other multi-purpose infrastructure. Workflow jobs execute with the permissions of the runner service account and the Chromium workspace persists between builds.

The runner service account is `github-runner` by default and MUST NOT retain passwordless sudo access.

## Initial host

The first supported runner host is Linux x86-64 on an apt-based distribution.

For predictable Chromium dependency installation, Ubuntu is the preferred first host. Other distributions can be added after they are validated.

Practical host sizing should exceed Chromium's minimums. Use fast SSD/NVMe storage and leave substantial capacity beyond the checkout/build minimum so multiple output trees and caches do not exhaust the filesystem.

## GitHub labels

The full-build workflow requires:

```text
self-hosted
linux
x64
chromium-builder
```

The first three labels are assigned automatically by GitHub's Linux x64 runner. `chromium-builder` is assigned by the registration script.

## Phase 1: prepare the machine

Clone this private repository onto the future runner host, then run:

```bash
sudo bash scripts/runner/prepare-linux-x64.sh
```

This phase:

1. installs bootstrap packages;
2. creates the dedicated `github-runner` service account;
3. creates `/srv/kitech-browser-ci-workspace`;
4. bootstraps the pinned `depot_tools` and Chromium M151 checkout;
5. temporarily grants the service account sudo only while Chromium's pinned dependency installer runs;
6. runs Chromium hooks;
7. verifies the exact Chromium revision;
8. removes the temporary sudo permission before any Actions runner service is installed.

The persistent workspace can be overridden:

```bash
sudo KITECH_BROWSER_WORKSPACE=/path/to/workspace \
  bash scripts/runner/prepare-linux-x64.sh
```

## Phase 2: obtain GitHub registration values

After machine preparation is complete, open:

```text
browser-core-chromium
→ Settings
→ Actions
→ Runners
→ New self-hosted runner
→ Linux
→ x64
```

Use the runner version, SHA-256 checksum, and short-lived registration token shown by GitHub.

Do not commit or persist the registration token.

The repository defaults to runner version `2.336.0`, but the version shown in the repository's GitHub runner instructions is authoritative if it differs.

## Phase 3: register the runner

Set the values without putting the registration token directly into shell history:

```bash
read -rsp 'Runner registration token: ' RUNNER_TOKEN
echo
export RUNNER_TOKEN

export RUNNER_SHA256='<linux-x64-sha256-from-github>'
export RUNNER_VERSION='2.336.0' # use the version GitHub shows

sudo --preserve-env=RUNNER_TOKEN,RUNNER_SHA256,RUNNER_VERSION \
  bash scripts/runner/register-linux-x64.sh

unset RUNNER_TOKEN
```

The registration script:

- verifies the downloaded runner archive against the supplied SHA-256;
- registers only against `daijingroup/browser-core-chromium`;
- adds the `chromium-builder` label;
- configures the persistent Chromium workspace through the runner `.env` file;
- installs the runner under `/opt/github-actions-runner/browser-core-chromium`;
- runs the service as the unprivileged `github-runner` account.

## Verify

On GitHub, return to:

```text
Settings → Actions → Runners
```

The runner should show as idle with these labels:

```text
self-hosted, linux, x64, chromium-builder
```

Then manually dispatch **Full Chromium Core Build** from the Actions tab.

The workflow validates the core manifests, reuses the prepared Chromium workspace, builds the `chrome` target, records provenance, and runs the headless smoke test.

## Updates

Leave GitHub Actions runner automatic updates enabled. If automatic updates are ever disabled, runner updates become an explicit maintenance responsibility and must remain within GitHub's supported update window.

Chromium itself remains pinned and is updated only through the browser release/upstream policy.
