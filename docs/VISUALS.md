# Visual language: stones and still water

Depress-o-buster's imagery follows one metaphor. A **stone** is one small step: solid, low,
something you can put a foot on without deciding anything. **Still water** is rest: it is
not empty, it is the part of the method that holds the stone up. Progress is a **cairn**,
stones stacked one at a time, which only ever grows. Nothing in the imagery hurries, points,
cheers, or frowns.

This document is the contract for every image in the app: the brand mark, the in-app
illustrations, the procedural widgets, and the screenshots. A designer can replace any
illustration by dropping in a new SVG with the same file name, as long as it keeps to the
rules below.

## Palette

Illustrations are authored for the dark theme using these exact hex values. At runtime
`PaletteMapper` (in `lib/ui/widgets/illustration.dart`) swaps each one for its light-theme
counterpart, so an SVG must use **only** these colours (opacity is free).

| Token      | Dark (author with this) | Light (mapped at runtime) | Use                                   |
|------------|-------------------------|---------------------------|---------------------------------------|
| stone      | `#8FB39A`               | `#4E7A5C`                 | The stone you are approaching          |
| water      | `#8E9BC7`               | `#59689E`                 | Ripples, the water line, rest, moon    |
| ink        | `#E6E8EA`               | `#23272B`                 | Highlights, the sun's edge, soft light |
| muted      | `#9AA3AB`               | `#5F6B74`                 | Other stones, distant shapes           |
| surface    | `#1F2328`               | `#E9E7E1`                 | Ground, the far bank, filled areas     |
| background | `#0F1114`               | `#F4F3EF`                 | Only to knock out shapes; never a rect that fills the canvas |
| glint      | `#FFFFFF`               | `#FFFFFF` (unchanged)     | A highlight on a stone, at 0.10 to 0.18 opacity; always light |

`ink` is "the opposite of the background": pale on dark, dark on light. Use it for light in the
sky and anything that must contrast with the background in both themes. A highlight on a stone
must stay light in both themes, so it uses `glint`, never `ink`.

Stones never get an outline. Water is always a stroke. Opacity is how depth is shown:
the nearest thing is fully opaque, the farthest is around 0.25.

## In-app illustrations

All live in `assets/illustrations/` as PNGs prepared by `tool/brand/prepare_illustration.py`
from the paintings in `assets/images/`: trimmed, padded to a 3:2 frame with a little air,
1440 × 960, their own colours on both themes (the paintings' outline reads on charcoal and
off-white alike). Two pebbles alternate across the slots, the one at rest and the one
standing, so the set stays quiet.

| File               | Source                     | Where it appears                                        |
|--------------------|----------------------------|---------------------------------------------------------|
| `stone_still.png`  | `pebble-2.png` (at rest)   | Start tab, above the one-tap button                     |
| `stone_dawn.png`   | `pebble.png` (standing)    | Start tab after three or more quiet days; rest complete |
| `path_ahead.png`   | `pebbles.png`              | Running approach                                        |
| `rest_moon.png`    | `moon.png`                 | Running rest                                            |
| `ripple_done.png`  | `pebble-2.png` (at rest)   | Approach complete                                       |
| `stones_empty.png` | `pebble.png` (standing)    | Tasks tab with no tasks                                 |
| `water_quiet.png`  | `pebble-2.png` (at rest)   | Empty history and progress                              |
| `stone_split.png`  | `pebble.png` (standing)    | "Break this down smaller" sheet                         |

```sh
python3 tool/brand/prepare_illustration.py assets/images/pebble-2.png stone_still
```

To change a slot, prepare a different painting under the same name. Hard rules for any new
painting: calm over clever (no faces, characters, confetti, arrows, checkmarks, trophies,
exclamation marks, speed lines), a transparent background, and nothing that implies hurry
or judgement.

### Vector illustrations (the fallback contract)

A slot can also be an SVG, `viewBox="0 0 240 160"`, no fixed `width`/`height`, authored for
the dark theme in the palette above; `PaletteMapper` swaps the colours for the light theme.
Stones are rounded pebbles with a slightly flatter underside, rings are thin elliptical
strokes, a horizon is a single faint line at y = 104. Only the flutter_svg subset: `path`,
`circle`, `ellipse`, `rect`, `line`, `polyline`, `polygon`, `g`, `defs`, gradients and
`clipPath`; no `filter`, `style`, `text`, `image`, `mask` or `use`; six-digit hex colours
only; under 4 KB. The original vector set lives in git history (before the paintings) and
`assets/brand/mark*.svg` keeps the vector mark they were drawn to match.

## Brand mark

The app icon is a painted pebble, `assets/images/pebble.png` (1024 px, transparent background),
and the splash screens show its companion at rest, `assets/images/pebble-2.png`.
`tool/brand/apply_icon.py` turns them into every file the generators consume, under
`assets/brand/`:

| File                    | Used for                                                     |
|-------------------------|--------------------------------------------------------------|
| `mark.png`              | App icon on its off-white background: iOS, legacy Android, web, macOS, the About row |
| `mark_foreground.png`   | Android adaptive icon foreground (artwork inside the 66 % safe zone) |
| `mark_mono.png`         | Android 13+ themed icon (one flat white silhouette)          |
| `mark_transparent.png`  | iOS 18 dark and tinted icons                                 |
| `splash_mark.png`       | Splash screens (shown at 160 dp on the theme background)     |
| `splash_android12.png`  | Android 12+ splash icon (1152 px canvas, 768 px circle)      |

```sh
python3 tool/brand/apply_icon.py assets/images/pebble.png --splash assets/images/pebble-2.png
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Both generators read their configuration from `pubspec.yaml`. Commit the generated platform
files. A new painting only needs to be dropped in as `pebble.png` (or `pebble-2.png` for the splash)
and the three commands re-run; `--background "#0F1114"` puts the icon on charcoal instead.

The earlier vector mark (`assets/brand/mark*.svg`, generated by `tool/brand/build_brand.py`)
is kept as the fallback the in-app illustrations are drawn to match; the pebble's silhouette
still follows it.

The Android notification glyph (`android/app/src/main/res/drawable/ic_stat_stone.xml`) is a
hand-drawn 24 dp vector, because Android renders small icons as a white silhouette and
tints them.

## Procedural widgets

Two images are drawn in code because they depend on state:

- **`Cairn`** (`lib/ui/widgets/cairn.dart`): the level badge. Level 1 is a single stone
  lying flat; each level adds a stone until nine, then the cairn is complete and stays.
  It never shrinks, which matches the XP rules (the multiplier never resets).
- **`RippleCelebration`** (`lib/ui/widgets/ripple_celebration.dart`): one slow ring that
  spreads and fades behind the "+XP" line on a first-ever interval, a new personal step,
  or a level up. One ring, 1.8 s, never louder than 35 % opacity. It is skipped entirely
  when the platform asks for reduced motion.

## Screenshots

`docs/screenshots/*.png` are rendered by a tagged widget test, not taken from a device, so
they can be regenerated without a phone:

```sh
flutter test test/screenshots/screenshots_test.dart --dart-define=SCREENSHOTS=true --update-goldens
```

They use Roboto and the Material icon font from the Flutter SDK cache, an in-memory
database with the starter tasks and a few logged intervals, and a 390 × 844 logical
viewport at 3×. The same test is skipped in a normal `flutter test` run.
