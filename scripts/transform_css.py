#!/usr/bin/env python3
import re
import sys
from pathlib import Path

CLASS_SELECTOR = re.compile(r"(?<![A-Za-z0-9_-])\.([A-Za-z_][A-Za-z0-9_-]*)")
PREFIXED_CLASS = re.compile(r"\.ShearWeb_([A-Za-z0-9_-]+)")

def main() -> int:
    if len(sys.argv) != 3:
        print("usage: transform_css.py <input.css> <output.css>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    text = src.read_text(encoding="utf-8")

    # 1) Add ShearWeb_ prefix to CSS class selectors.
    text = CLASS_SELECTOR.sub(r".ShearWeb_\1", text)

    # 2) Replace '-' with '_' within prefixed class names.
    text = PREFIXED_CLASS.sub(lambda m: ".ShearWeb_" + m.group(1).replace("-", "_"), text)

    dst.write_text(text, encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
