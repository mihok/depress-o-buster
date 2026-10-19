#!/usr/bin/env python3
"""Writes the brand mark SVG variants from one source of truth.

The mark is a single stone resting in still water: one small step, and the
rest around it. Run `python3 tool/brand/build_brand.py` after editing the shapes
below, then `node tool/brand/rasterize.js` to refresh the PNGs that the icon and
splash generators consume (see docs/VISUALS.md).
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets" / "brand"

BACKGROUND = "#0F1114"
STONE = "#8FB39A"       # AppColors.approach
RIPPLE = "#8E9BC7"      # AppColors.rest
HIGHLIGHT = "#E6E8EA"   # AppColors.darkText

# The artwork lives in a 1024x1024 box centred on (512, 512); the stone sits a
# little above centre so the ripples below it have room.
def art(stone: str, ripple: str, highlight: str | None, mono: bool = False) -> str:
    rings = (
        f'<ellipse cx="512" cy="588" rx="300" ry="64" fill="none" stroke="{ripple}" '
        f'stroke-width="18" stroke-opacity="{1 if mono else 0.62}"/>\n'
        f'    <ellipse cx="512" cy="600" rx="420" ry="96" fill="none" stroke="{ripple}" '
        f'stroke-width="14" stroke-opacity="{1 if mono else 0.3}"/>'
    )
    stone_path = (
        "M 300 478 C 300 392, 404 338, 526 342 C 648 346, 724 404, 722 486 "
        "C 720 560, 642 596, 514 596 C 390 596, 300 560, 300 478 Z"
    )
    light = (
        f'\n    <ellipse cx="470" cy="420" rx="118" ry="44" fill="{highlight}" '
        f'fill-opacity="0.14" transform="rotate(-8 470 420)"/>'
        if highlight and not mono else ""
    )
    return (
        f"    {rings}\n"
        f'    <path d="{stone_path}" fill="{stone}"/>{light}'
    )


def svg(body: str, background: str | None, scale: float, size: int = 1024) -> str:
    bg = f'  <rect width="{size}" height="{size}" fill="{background}"/>\n' if background else ""
    # Scale about the centre of the canvas.
    c = size / 2
    t = f'translate({c:.1f} {c:.1f}) scale({scale}) translate(-512 -512)'
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {size} {size}" width="{size}" height="{size}">\n'
        f"{bg}"
        f'  <g transform="{t}">\n{body}\n  </g>\n'
        "</svg>\n"
    )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    full = art(STONE, RIPPLE, HIGHLIGHT)
    mono = art("#FFFFFF", "#FFFFFF", None, mono=True)
    files = {
        # App icon with its own background (iOS, legacy Android, web, macOS).
        "mark.svg": svg(full, BACKGROUND, 0.92),
        # Adaptive icon foreground: artwork inside the inner 66% safe zone.
        "mark_foreground.svg": svg(full, None, 0.60),
        # Android 13+ themed icon: one flat silhouette, tinted by the launcher.
        "mark_mono.svg": svg(mono, None, 0.60),
        # Transparent artwork for the iOS 18 dark icon and the splash images.
        "mark_transparent.svg": svg(full, None, 0.92),
        # Android 12+ splash icon: 1152 px canvas, artwork within a 768 px circle.
        "splash_android12.svg": svg(full, None, 0.60, size=1152),
    }
    for name, content in files.items():
        (OUT / name).write_text(content)
        print("wrote", OUT / name)


if __name__ == "__main__":
    main()
