#!/usr/bin/env python3
"""Probe measure env: real Python + any usable pixel backend. cv2 not required."""
from __future__ import annotations

import subprocess
import sys


def fail(tool: str, reason: str) -> None:
    print(f"FAIL|{tool}|{reason}")


def pip_install(pkg: str) -> None:
    subprocess.run(
        [sys.executable, "-m", "pip", "install", pkg],
        check=False,
        capture_output=True,
    )


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


def main() -> int:
    if sys.version_info < (3, 10):
        fail("python", f"need 3.10+, got {sys.version.split()[0]}")
        return 1
    if "WindowsApps" in sys.executable.replace("\\", "/"):
        fail("python", "WindowsApps stub; set PYTHON_EXE to real python.exe")
        return 1
    print(f"OK|python|{sys.executable}|Python {sys.version.split()[0]}")

    pil_ver = try_pillow()
    if pil_ver is None:
        fail("pillow", "missing; pip install Pillow once")
        pip_install("Pillow")
        pil_ver = try_pillow()
    if pil_ver:
        print(f"OK|pillow|{pil_ver}")
    else:
        fail("pillow", "unusable after pip install once")

    cv2_ver = try_cv2()
    if cv2_ver is None:
        fail("cv2", "optional; pip install opencv-python once")
        pip_install("opencv-python")
        cv2_ver = try_cv2()
    if cv2_ver is None:
        pip_install("opencv-python-headless")
        cv2_ver = try_cv2()
    if cv2_ver:
        print(f"OK|cv2|{cv2_ver}")
    else:
        fail("cv2", "optional; not required if pillow OK")

    if pil_ver or cv2_ver:
        print("OK|measure|use any OK backend; prefer whichever is accurate for the task")
        return 0
    fail("measure", "no usable pixel backend; do not estimate")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
