#!/usr/bin/env python3
"""On-demand pixel backend probe. Installation requires explicit --repair."""
from __future__ import annotations

import argparse
import subprocess
import sys


def fail(tool: str, reason: str) -> None:
    print(f"FAIL|{tool}|{reason}")


def pip_install(pkg: str) -> bool:
    try:
        result = subprocess.run(
            [sys.executable, "-m", "pip", "install", pkg],
            check=False,
            capture_output=True,
            timeout=120,
        )
        return result.returncode == 0
    except (OSError, subprocess.TimeoutExpired):
        return False


def try_pillow() -> str | None:
    try:
        import PIL
        from PIL import Image  # noqa: F401
        return str(PIL.__version__)
    except Exception:
        return None


def try_cv2() -> str | None:
    try:
        import cv2
        return str(cv2.__version__)
    except Exception:
        return None


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repair", action="store_true",
                        help="If no backend works, attempt Pillow installation once.")
    args = parser.parse_args(argv)
    if sys.version_info < (3, 10):
        fail("python", f"need 3.10+, got {sys.version.split()[0]}")
        return 1
    if "windowsapps" in sys.executable.replace("\\", "/").lower():
        fail("python", "WindowsApps stub; set PYTHON_EXE to real python.exe")
        return 1
    print(f"OK|python|{sys.executable}|Python {sys.version.split()[0]}")

    pil_ver = try_pillow()
    cv2_ver = try_cv2()
    if not pil_ver and not cv2_ver and args.repair:
        print("REPAIR|pillow|one installation attempt")
        pip_install("Pillow")
        pil_ver = try_pillow()

    if pil_ver:
        print(f"OK|pillow|{pil_ver}")
    else:
        fail("pillow", "unavailable")
    if cv2_ver:
        print(f"OK|cv2|{cv2_ver}")
    else:
        print("SKIP|cv2|optional backend unavailable")

    if pil_ver or cv2_ver:
        print("OK|measure|use any available backend; measure the actual input")
        return 0
    fail("measure", "no usable pixel backend; exact pixel fields remain incomplete")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
