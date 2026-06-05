#!/usr/bin/env python3
import re
import sys
from pathlib import Path

MAPPINGS = [
    (r"\.container\b", ".ShearWeb_container"),
    (r"\.spacer\b", ".ShearWeb_spacer"),
    (r"\.content\b", ".ShearWeb_content"),
    (r"\.tile\b", ".ShearWeb_tile"),
    (r"\.is-ancestor\b", ".ShearWeb_is_ancestor"),
    (r"\.is-parent\b", ".ShearWeb_is_parent"),
    (r"\.notification\b", ".ShearWeb_notification"),
    (r"\.is-light\b", ".ShearWeb_is_light"),
    (r"\.subtitle\b", ".ShearWeb_subtitle"),
    (r"\.is-vertical\b", ".ShearWeb_is_vertical"),
    (r"\.is-5\b", ".ShearWeb_is_5"),
    (r"\.is-child\b", ".ShearWeb_is_child"),
    (r"\.box\b", ".ShearWeb_box"),
    (r"\.is-7\b", ".ShearWeb_is_7"),
    (r"\.footer\b", ".ShearWeb_footer_cls"),
    (r"\.is-size-7\b", ".ShearWeb_is_size_7"),
]

def main() -> int:
    if len(sys.argv) != 3:
        print("usage: transform_css.py <input.css> <output.css>", file=sys.stderr)
        return 2

    src = Path(sys.argv[1])
    dst = Path(sys.argv[2])

    text = src.read_text(encoding="utf-8")
    for pattern, replacement in MAPPINGS:
        text = re.sub(pattern, replacement, text)

    dst.write_text(text, encoding="utf-8")
    return 0

if __name__ == "__main__":
    raise SystemExit(main())
