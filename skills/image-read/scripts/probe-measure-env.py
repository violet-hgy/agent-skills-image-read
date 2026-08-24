#!/usr/bin/env python3
"""Probe Python 3.10+ and Pillow for ImageRead. cv2 is not required."""
from __future__ import annotations

import sys


def fail(tool: str, reason: str) -> int:
    print(f"FAIL|{tool}|{reason}")
    return 1


def main() -> int:
    if sys.version_info < (3, 10):
        return fail("python", f"need 3.10+, got {sys.version.split()[0]}")
    exe = sys.executable.replace("\\", "/")
    if "WindowsApps" in exe:
        return fail("python", "WindowsApps stub; set PYTHON_EXE to real python.exe")
    print(f"OK|python|{sys.executable}|Python {sys.version.split()[0]}")
    try:
        import PIL
        from PIL import Image  # noqa: F401
    except Exception as exc:
        return fail("pillow", str(exc))
    print(f"OK|pillow|{PIL.__version__}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
