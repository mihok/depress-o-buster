#!/usr/bin/env python3
"""Fits a painted illustration into the app's 3:2 illustration frame.

    python3 tool/brand/prepare_illustration.py <source.png> <name>

Trims the transparent margin, pads to 3:2 with a little air (the same frame
the SVG illustrations use), resizes to 1440 x 960 and writes
assets/illustrations/<name>.png. The source keeps its own colours, so one
file serves both themes; it is not run through the palette mapper.
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "illustrations"
W, H = 1440, 960
AIR = 0.06  # fraction of the frame kept clear on every side


def main() -> int:
    src, name = sys.argv[1], sys.argv[2]
    im = Image.open(src).convert("RGBA")
    box = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    art = im.crop(box) if box else im
    inner_w, inner_h = W * (1 - 2 * AIR), H * (1 - 2 * AIR)
    scale = min(inner_w / art.width, inner_h / art.height)
    art = art.resize((round(art.width * scale), round(art.height * scale)), Image.LANCZOS)
    out = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    # Sit the artwork a touch below centre, like the SVGs' water line.
    out.alpha_composite(art, ((W - art.width) // 2, min(H - art.height, (H - art.height) // 2 + H // 20)))
    OUT.mkdir(parents=True, exist_ok=True)
    out.save(OUT / f"{name}.png", optimize=True)
    print(f"wrote {OUT / name}.png {out.size[0]}x{out.size[1]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
