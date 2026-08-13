#!/usr/bin/env python3
from __future__ import annotations

import argparse
import datetime as dt
import hashlib
import json
import pathlib
import subprocess
import tomllib

ROOT = pathlib.Path(__file__).resolve().parents[1]


def load_toml(path: pathlib.Path) -> dict:
    return tomllib.loads(path.read_text(encoding="utf-8"))


def git_head(path: pathlib.Path) -> str:
    return subprocess.check_output(
        ["git", "-C", str(path), "rev-parse", "HEAD"], text=True
    ).strip()


def sha256(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("workspace", type=pathlib.Path)
    parser.add_argument("profile", choices=("dev", "release"))
    parser.add_argument("target")
    args = parser.parse_args()

    core = load_toml(ROOT / "config/core.toml")
    chromium = load_toml(ROOT / "config/chromium.toml")
    depot = load_toml(ROOT / "config/depot_tools.toml")

    chromium_src = args.workspace / "chromium" / "src"
    depot_dir = args.workspace / "depot_tools"
    out_name = "KiTechDev" if args.profile == "dev" else "KiTechRelease"
    out_dir = chromium_src / "out" / out_name
    args_gn = out_dir / "args.gn"

    manifest = {
        "schema_version": 1,
        "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "core": {
            "api": core["core_api"],
            "repository_revision": git_head(ROOT),
        },
        "chromium": {
            "milestone": chromium["milestone"],
            "tag": chromium["tag"],
            "declared_revision": chromium["revision"],
            "actual_revision": git_head(chromium_src),
        },
        "depot_tools": {
            "declared_revision": depot["revision"],
            "actual_revision": git_head(depot_dir),
        },
        "build": {
            "profile": args.profile,
            "target": args.target,
            "args_gn_sha256": sha256(args_gn),
        },
    }

    output = out_dir / "kitech-build-manifest.json"
    output.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(output)


if __name__ == "__main__":
    main()
