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

All live in `assets/illustrations/`, `viewBox="0 0 240 160"`, no fixed `width`/`height`
attributes. The water line sits at **y = 104** unless the brief says otherwise; everything
rests on or above it. Keep 12 px of air on every side. One subject, centred or slightly
left of centre. At most three palette colours per file.

Stones are rounded pebbles with a slightly flatter underside, drawn as a single cubic path.
Ripples are elliptical arcs or ellipses with `stroke-width` 1.5 to 2.5 and `fill="none"`.
A horizon is a single 1.5 px line at the water line, at 0.3 to 0.5 opacity, often shorter
than the full width.

| File               | Where it appears                                   | What it says                                                        |
|--------------------|----------------------------------------------------|---------------------------------------------------------------------|
| `stone_still.svg`  | Start tab, above the one-tap button                | One stone, still water, one faint ring. Nothing is required of you. |
| `stone_dawn.svg`   | Start tab after three or more quiet days; rest complete | The same stone with soft light low on the horizon. Good to see you. |
| `path_ahead.svg`   | Running approach                                   | A near stone, two further ones fading away. Being near the thing.  |
| `rest_moon.svg`    | Running rest                                       | A thin moon over still water, no stone. Rest is the method too.    |
| `ripple_done.svg`  | Approach complete                                  | The stone with two rings spreading from it. That counted.          |
| `stones_empty.svg` | Tasks tab with no tasks                            | Three small stones in a loose line going away. Pick one up.        |
| `water_quiet.svg`  | Empty history and progress                         | Water only, one ring. Nothing logged yet, and that is fine.        |
| `stone_split.svg`  | "Break this down smaller" sheet                    | One stone above, three pebbles below it. Smaller is still a step.  |

Hard rules, in order of importance:

1. **Calm over clever.** No faces, characters, confetti, stars bursting, arrows, checkmarks,
   trophies, exclamation marks, speed lines, or anything that implies hurry or judgement.
2. **Dark first.** Author on `#0F1114`; check on `#F4F3EF` too (the mapper handles colours,
   but the composition must still read when the light theme inverts the contrast).
3. **flutter_svg subset only.** `path`, `circle`, `ellipse`, `rect`, `line`, `polyline`,
   `polygon`, `g`, `defs`, `linearGradient`, `radialGradient`, `clipPath`. Attributes:
   `fill`, `stroke`, `stroke-width`, `stroke-linecap`, `stroke-linejoin`,
   `stroke-dasharray`, `opacity`, `fill-opacity`, `stroke-opacity`, `transform`.
   **No** `filter`, `style` blocks, CSS classes, `text`, `image`, `mask`, `use`, or
   `foreignObject`. Colours as 6-digit hex only.
4. **Small files.** Under 4 KB each. A handful of shapes, not a trace of a painting.

## Brand mark

`assets/brand/mark*.svg` are generated by `tool/brand/build_brand.py` from one set of
shapes: the stone, two rings, a soft highlight. Variants:

| File                    | Used for                                                     |
|-------------------------|--------------------------------------------------------------|
| `mark.svg`              | App icon with its own background: iOS, legacy Android, web, macOS |
| `mark_foreground.svg`   | Android adaptive icon foreground (artwork inside the 66 % safe zone) |
| `mark_mono.svg`         | Android 13+ themed icon (one flat silhouette)                |
| `mark_transparent.svg`  | iOS 18 dark icon and the splash images                       |
| `splash_android12.svg`  | Android 12+ splash icon (1152 px canvas, 768 px circle)      |

The PNGs next to them are rasterised with `node tool/brand/rasterize.js <svg> <png> <size>`
(Playwright's Chromium; any SVG rasteriser works). The icons and splash screens are then
generated into each platform folder:

```sh
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Both read their configuration from `pubspec.yaml`. Commit the generated platform files.

The Android notification glyph (`android/app/src/main/res/drawable/ic_stat_stone.xml`) is
the monochrome mark redrawn by hand as a 24 dp vector drawable, because Android renders
small icons as a white silhouette and tints them.

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
