#!/usr/bin/env python3
from __future__ import annotations

import pathlib
import re
import sys
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[1]
HEX40 = re.compile(r"^[0-9a-f]{40}$")


def load(path: str) -> dict:
    return tomllib.loads((ROOT / path).read_text(encoding="utf-8"))


def fail(message: str) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(1)


def main() -> None:
    chromium = load("config/chromium.toml")
    depot = load("config/depot_tools.toml")
    core = load("config/core.toml")

    if chromium.get("state") != "pinned":
        fail("Chromium state must be pinned")
    revision = str(chromium.get("revision", ""))
    if not HEX40.fullmatch(revision):
        fail("Chromium revision must be a 40-character lowercase git SHA")
    milestone = chromium.get("milestone")
    tag = str(chromium.get("tag", ""))
    if not isinstance(milestone, int) or milestone <= 0:
        fail("Chromium milestone must be a positive integer")
    if not tag.startswith(f"{milestone}."):
        fail("Chromium tag must match the declared milestone")

    depot_revision = str(depot.get("revision", ""))
    if not HEX40.fullmatch(depot_revision):
        fail("depot_tools revision must be a 40-character lowercase git SHA")
    if depot.get("auto_update") is not False:
        fail("depot_tools auto_update must remain false for reproducible builds")

    core_api = core.get("core_api")
    if not isinstance(core_api, int) or core_api <= 0:
        fail("core_api must be a positive integer")
    hosts = core.get("supported_hosts", [])
    if "linux-x86_64" not in hosts:
        fail("initial core must retain linux-x86_64 in supported_hosts")

    for profile in ("dev", "release"):
        if not (ROOT / "config" / "gn" / f"{profile}.gn").is_file():
            fail(f"missing GN profile: {profile}")

    manifest = ROOT / "config" / "patches.list"
    for raw in manifest.read_text(encoding="utf-8").splitlines():
        entry = raw.split("#", 1)[0].strip()
        if not entry:
            continue
        path = pathlib.PurePosixPath(entry)
        if path.is_absolute() or ".." in path.parts:
            fail(f"invalid patch path: {entry}")
        if not entry.startswith("patches/"):
            fail(f"patch must live under patches/: {entry}")
        if not (ROOT / entry).is_file():
            fail(f"patch manifest entry does not exist: {entry}")

    print(
        f"core configuration valid: api={core_api} chromium={tag} revision={revision}"
    )


if __name__ == "__main__":
    main()
