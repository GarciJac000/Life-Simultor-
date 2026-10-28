#!/usr/bin/env python3
"""Dependency-free CI-style Godot import, physics/UI integration, export, and boot checks."""
import os
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
GODOT = os.environ.get("GODOT", "godot")


def run(args, env, expected=None):
    command = [GODOT, "--headless", "--path", str(ROOT), *args]
    result = subprocess.run(command, env=env, text=True, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, timeout=240)
    print(result.stdout, end="")
    if result.returncode or re.search(r"(?:SCRIPT ERROR:|ERROR:)", result.stdout):
        raise SystemExit(f"Check failed: {args} (exit {result.returncode})")
    if expected and not re.search(expected, result.stdout):
        raise SystemExit(f"Missing successful outcome: {expected}")


def main():
    with tempfile.TemporaryDirectory(prefix="life-mode-checks-") as folder:
        tmp = Path(folder)
        env = os.environ.copy()
        for suffix in ("DATA", "CONFIG", "CACHE"):
            path = tmp / suffix.lower()
            path.mkdir()
            env.setdefault(f"XDG_{suffix}_HOME", str(path))
        version = subprocess.check_output([GODOT, "--version"], env=env, text=True).strip()
        if not version.startswith("4.7.2.stable"):
            raise SystemExit(f"Expected Godot 4.7.2 stable, found {version}. Set GODOT to its executable.")
        print(f"ENGINE / {version}")
        run(["--editor", "--import", "--quit"], env)
        run(["--fixed-fps", "60", "--script", "res://tests/smoke.gd"], env,
            r"RESULT / [1-9]\d* checks, 0 failures")
        pack = tmp / "life-mode.pck"
        run(["--export-pack", "Linux", str(pack)], env)
        if not pack.is_file() or pack.stat().st_size == 0:
            raise SystemExit("Resource export missing or empty")
        run(["--main-pack", str(pack), "--quit-after", "120"], env)
        print("CHECKS PASSED / editor import, integration suite, resource-pack export, packed boot")


if __name__ == "__main__":
    main()
