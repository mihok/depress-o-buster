#!/usr/bin/env python3
"""Turns one painted icon PNG into every brand file the generators consume.

    python3 tool/brand/apply_icon.py <source.png> [--splash <other.png>] [--background #F4F3EF] [--scale 0.78]

The source is square-ish artwork of the stone on a transparent or plain white
background (white is keyed out softly; edges are kept). `--splash` names a
second painting for the splash screens only (a stone at rest, say). It
writes, under assets/brand/:

  mark.png              1024, the artwork on the background colour (iOS, legacy Android, web, macOS)
  mark_foreground.png   1024, transparent, artwork inside the adaptive safe zone (626 px circle)
  mark_mono.png         1024, transparent, one white silhouette for themed icons
  mark_transparent.png  1024, transparent, artwork at icon scale (iOS 18 dark and tinted)
  splash_mark.png        640, transparent, for the splash screens (shown at 160 dp)
  splash_android12.png  1152, transparent, artwork inside the 768 px circle

Then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`.
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageFilter

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "brand"


def key_white(im: Image.Image) -> Image.Image:
    """Make near-white pixels transparent with a soft ramp, keeping edges."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            m = min(r, g, b)
            if m >= 250:
                px[x, y] = (r, g, b, 0)
            elif m > 225:
                # 226..249: fade out; the artwork's own pale tones stay above 225
                px[x, y] = (r, g, b, int(a * (250 - m) / 25))
    return im


def has_real_alpha(im: Image.Image) -> bool:
    if im.mode not in ("RGBA", "LA") and "transparency" not in im.info:
        return False
    lo, hi = im.convert("RGBA").getchannel("A").getextrema()
    return lo < 250


def trimmed(im: Image.Image) -> Image.Image:
    box = im.getchannel("A").point(lambda v: 255 if v > 8 else 0).getbbox()
    return im.crop(box) if box else im


def place(art: Image.Image, canvas: int, span: float, background=None) -> Image.Image:
    """Centre the artwork so its longer side spans `span` of the canvas."""
    art = trimmed(art)
    scale = canvas * span / max(art.size)
    size = (max(1, round(art.width * scale)), max(1, round(art.height * scale)))
    art = art.resize(size, Image.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), background or (0, 0, 0, 0))
    out.alpha_composite(art, ((canvas - size[0]) // 2, (canvas - size[1]) // 2))
    return out


def silhouette(art: Image.Image) -> Image.Image:
    """One flat white shape from the artwork's alpha, holes filled a little."""
    a = art.getchannel("A").point(lambda v: 255 if v > 60 else 0)
    a = a.filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.MinFilter(5))
    white = Image.new("RGBA", art.size, (255, 255, 255, 255))
    white.putalpha(a)
    return white


def hex_rgb(s: str):
    s = s.lstrip("#")
    return tuple(int(s[i : i + 2], 16) for i in (0, 2, 4)) + (255,)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("source")
    ap.add_argument("--splash", help="a different painting for the two splash files")
    ap.add_argument("--background", default="#F4F3EF", help="icon background colour")
    ap.add_argument("--scale", type=float, default=0.78, help="artwork span of the full icon")
    args = ap.parse_args()

    def load(path: str) -> Image.Image:
        im = Image.open(path)
        return im.convert("RGBA") if has_real_alpha(im) else key_white(im)

    art = load(args.source)
    splash_art = load(args.splash) if args.splash else art
    bg = hex_rgb(args.background)
    OUT.mkdir(parents=True, exist_ok=True)

    full = place(art, 1024, args.scale, background=bg)
    full.convert("RGB").save(OUT / "mark.png")
    place(art, 1024, args.scale).save(OUT / "mark_transparent.png")
    # Adaptive foreground: inside the inner 66 % (a 626 px circle of 1024),
    # so the longer side spans about 58 %.
    fg = place(art, 1024, 0.58)
    fg.save(OUT / "mark_foreground.png")
    silhouette(fg).save(OUT / "mark_mono.png")
    place(splash_art, 640, args.scale).save(OUT / "splash_mark.png")
    # Android 12: a 1152 canvas, artwork inside the centred 768 px circle.
    place(splash_art, 1152, 0.52).save(OUT / "splash_android12.png")
    for name in ["mark", "mark_transparent", "mark_foreground", "mark_mono", "splash_mark", "splash_android12"]:
        im = Image.open(OUT / f"{name}.png")
        print(f"{name}.png {im.size[0]}x{im.size[1]} {im.mode}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
