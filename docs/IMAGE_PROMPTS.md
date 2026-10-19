# Image prompts for Kara AI

Everything the app shows is one metaphor: a **stone** is one small step, **still water** is
rest, and progress is a **cairn** that only grows. These prompts produce the production
versions of every image slot in that language. Generate them in one session so the model
keeps the style, and paste the **Style block** at the top of every prompt.

The app is dark-first with a light theme, so every in-app illustration is generated twice:
once for a near-black background and once for an off-white one. Icons and splash images are
generated once.

## Style block (paste first, every time)

```
STYLE: Minimal flat illustration with a soft matte finish and a very fine paper grain. Simple
rounded forms, no outlines, no hard edges, gentle diffuse light from the upper left. Low
contrast, generous negative space, serene and quiet, in the spirit of a Japanese dry garden
and Scandinavian minimalism. Smooth river stones with a slightly flattened underside. Still
water drawn as thin, soft elliptical ripple rings, never splashes or waves.

PALETTE (use only these): stone sage #8FB39A, deep sage #4E7A5C, dusk blue #8E9BC7, deep dusk
#59689E, warm off-white #F4F3EF, pale grey #E6E8EA, mid grey #9AA3AB, charcoal #0F1114.

AVOID: text, letters, numbers, logos, watermarks, people, hands, faces, animals, characters,
eyes on objects, sparkles, stars, confetti, sunbursts, lens flare, glow halos, neon, high
saturation, harsh shadows, glossy 3D render look, photorealism, busy backgrounds, borders,
frames, vignettes, drop shadows under the artwork.
```

Negative-prompt field, if the tool has one, gets the AVOID list verbatim.

## Sizes and backgrounds at a glance

| Slot                    | Size (px)   | Aspect | Background                         | Variants      |
|-------------------------|-------------|--------|------------------------------------|---------------|
| App icon                | 1024 × 1024 | 1:1    | Charcoal, full bleed               | 1             |
| App icon, foreground    | 1024 × 1024 | 1:1    | Transparent                        | 1             |
| Splash mark             | 1024 × 1024 | 1:1    | Transparent                        | 1             |
| In-app illustrations ×8 | 1440 × 960  | 3:2    | Transparent                        | dark + light  |
| Cairn badges ×9         | 600 × 720   | 5:6    | Transparent                        | dark + light  |
| README banner           | 1600 × 480  | 10:3   | Charcoal                           | 1             |
| Store feature graphic   | 1024 × 500  | ~2:1   | Charcoal                           | 1             |

"Dark variant" means the artwork is designed to sit on charcoal `#0F1114`: use sage
`#8FB39A` for the main stone, dusk blue `#8E9BC7` for water and rings, pale grey `#E6E8EA`
for any soft light, mid grey `#9AA3AB` for secondary stones. "Light variant" means it sits on
off-white `#F4F3EF`: use deep sage `#4E7A5C`, deep dusk `#59689E`, charcoal `#0F1114` at low
opacity for soft shade, and mid grey `#9AA3AB` for secondary stones. If the tool cannot
export transparency, generate on the exact background colour instead and say so when you
hand them over; a flat background can be keyed out.

## 1. App icon

Shown on the home screen at 48 to 60 px, so it must read as one shape. Nothing near the
edges: Android crops the outer 17 % into a circle or squircle.

```
[Style block]

App icon, 1024 x 1024, square, full-bleed charcoal #0F1114 background with no border or
rounded corners. A single smooth river stone in sage #8FB39A, slightly wider than tall, with a
flattened underside, resting in still water. The stone sits a little above centre. Below and
around it, two thin elliptical ripple rings in dusk blue #8E9BC7, the inner ring at about 60 %
opacity and the outer at about 30 %, partly hidden behind the stone so the stone reads as
sitting in the water. One soft, barely-there highlight on the upper left of the stone. The
whole composition fits inside the central 66 % of the canvas. Centred, symmetrical, calm.
```

### 1b. App icon, foreground only

```
[Style block]

The exact same stone and two ripple rings as the app icon, same proportions and placement,
on a fully transparent background, 1024 x 1024, with the artwork inside the central 60 % of
the canvas. No background shape of any kind.
```

### 1c. App icon, monochrome silhouette

Android 13 themed icons and the notification shade need one flat shape.

```
Flat white silhouette on a transparent background, 1024 x 1024: a smooth river stone with a
flattened underside, and beneath it two thin elliptical ring outlines, the outer one larger.
Pure white #FFFFFF only, no shading, no gradients, no grey, no anti-aliased soft edges beyond
what is needed. Artwork inside the central 60 % of the canvas.
```

## 2. Splash mark

Shown alone on a charcoal (dark mode) or off-white (light mode) screen for about a second.

```
[Style block]

The app's stone in still water with two ripple rings, exactly as in the app icon, on a fully
transparent background, 1024 x 1024, artwork spanning about 70 % of the width, centred. It
must look right on both charcoal #0F1114 and off-white #F4F3EF, so use sage #8FB39A for the
stone and dusk blue #8E9BC7 for the rings, and no pale glow.
```

## 3. In-app illustrations

All eight share the same framing: a horizontal 3:2 scene, 1440 × 960, the water line at
about 65 % of the height, one subject, centred or just left of centre, at least 8 % air on
every side, transparent background. Generate each one twice (dark variant, light variant)
using the colour notes above. Keep stones the same size and shape across the set, so the
eight feel like one series.

### 3a. `stone_still` — Start screen

What it says: nothing is required of you.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. One smooth river stone in [sage
#8FB39A / deep sage #4E7A5C] resting in still water, seen slightly from above. One faint
elliptical ripple ring in [dusk blue #8E9BC7 / deep dusk #59689E] around it at about 35 %
opacity, cut behind the stone. A short, quiet horizon line at the water level to the right of
the stone. Nothing else. Centred, lots of empty space, deeply calm.
```

### 3b. `stone_dawn` — Start screen after a few quiet days; rest complete

What it says: good to see you.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. The same river stone in [sage /
deep sage] in still water, with soft light low on the horizon behind it: a large, very faint
half-disc of [pale grey #E6E8EA / charcoal #0F1114] at about 12 % opacity resting on the water
line, and one or two wide, faint horizontal bands of light on the water. No sun rays, no
sunburst, no glow halo. A single faint ripple ring around the stone. Quiet, warm, unhurried.
```

### 3c. `path_ahead` — The running approach timer

What it says: being near the thing, one stone at a time.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. Stepping stones across still water:
a near stone in [sage / deep sage] at the lower left third, fully opaque, then two more stones
in mid grey #9AA3AB, each smaller and fainter (about 60 % and 35 % opacity), stepping away
toward the upper right. A faint ripple ring under each stone. No path line, no footprints,
no arrows: the stones themselves are the path.
```

### 3d. `rest_moon` — The running rest timer

What it says: rest is part of the method; there is nothing to approach.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. A thin crescent moon in [dusk blue
#8E9BC7 / deep dusk #59689E] high and slightly right of centre, over still water. Below it,
one soft horizontal band of reflected light on the water in the same colour at about 20 %
opacity, and a quiet horizon line. No stone at all, no stars, no clouds.
```

### 3e. `ripple_done` — Approach complete

What it says: that counted.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. The river stone in [sage / deep
sage] in still water with two elliptical ripple rings spreading from it in [dusk blue / deep
dusk]: the inner ring at about 60 % opacity, the outer ring noticeably larger at about 30 %.
Both rings are cut behind the stone. The stone sits just a touch higher than usual, as if it
has just settled. Gentle. No sparkle, no motion lines, no splash.
```

### 3f. `stones_empty` — Tasks screen with no tasks

What it says: pick one up.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. Three small river stones in mid
grey #9AA3AB in a loose, slightly curved line going away from the viewer across still water:
the nearest at the lower left fully opaque, the middle at about 70 %, the farthest at the
upper right at about 45 %. None is highlighted and none is green. A faint ring under each, a
quiet horizon line. Nothing beckons.
```

### 3g. `water_quiet` — Empty history and empty progress

What it says: nothing logged yet, and that is fine.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. Still water only: one faint
elliptical ripple ring in [dusk blue / deep dusk] at about 35 % opacity, a little left of
centre on the water line, a short horizon line, and optionally one very faint second ring far
to the right at about 15 %. No stone, no moon, no light. Almost nothing, and clearly part of
the same series.
```

### 3h. `stone_split` — "Break this down smaller" sheet

What it says: smaller is still a step.

```
[Style block]

Horizontal 3:2 scene, 1440 x 960, transparent background. One river stone in [sage / deep
sage] floating in the upper half, centred, a little smaller than usual. Below it, resting on
the water line, three small pebbles of the same colour at full, 80 % and 65 % opacity, spread
across the width. A faint ring under the pebbles. No arrows or lines connecting the stone to
the pebbles; the arrangement says it.
```

## 4. Cairn badges (optional, nine images)

The level badge is drawn in code today and does not need these. If you want painted ones,
generate a series of nine, one per stone count, and keep the base stone identical across all
nine so they read as the same cairn growing.

```
[Style block]

Vertical 5:6 image, 600 x 720, transparent background. A cairn of exactly N smooth river
stones stacked on a thin line of still water, each stone a little narrower than the one
beneath it, the stack settling slightly off a perfect column. The top stone in [sage #8FB39A /
deep sage #4E7A5C], the others in mid grey #9AA3AB, lower stones slightly more transparent.
A single faint water line under the base. Centred, calm, no shadow.
```

Run it for N = 1 ("one stone lying flat, wide and low") through N = 9. Name the files
`cairn_1_dark.png` … `cairn_9_light.png`.

## 5. README banner

```
[Style block]

Wide banner, 1600 x 480, charcoal #0F1114 background, no border. On the left third, the app's
stone in sage #8FB39A in still water with two dusk blue #8E9BC7 ripple rings, exactly as the
app icon. The right two thirds are empty charcoal, left clear for a title to be set in later.
A single thin horizon line in dusk blue at 35 % opacity runs from the stone toward the right
edge, fading out. No text.
```

## 6. Store feature graphic (Google Play)

```
[Style block]

Wide image, 1024 x 500, charcoal #0F1114 background, no border. Stepping stones across still
water from the lower left to the upper right: a near stone in sage #8FB39A, then three stones
in mid grey #9AA3AB, each smaller and fainter. A thin horizon line in dusk blue #8E9BC7 and a
faint ring under each stone. The upper left quarter stays empty for a title. No text.
```

## Handing the files back

Name the files exactly as the slot names above, with the variant as a suffix, and put them
in one folder:

```
icon.png  icon_foreground.png  icon_mono.png  splash.png
stone_still_dark.png  stone_still_light.png  stone_dawn_dark.png  stone_dawn_light.png
path_ahead_dark.png   path_ahead_light.png   rest_moon_dark.png   rest_moon_light.png
ripple_done_dark.png  ripple_done_light.png  stones_empty_dark.png stones_empty_light.png
water_quiet_dark.png  water_quiet_light.png  stone_split_dark.png stone_split_light.png
banner.png  feature_graphic.png  (cairn_1_dark.png … cairn_9_light.png, optional)
```

PNG, sRGB, transparent where the table says so. Then the wiring is mechanical:

* The icon and splash PNGs replace the ones in `assets/brand/` and the generators are re-run
  (`dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, see
  `docs/VISUALS.md`).
* The in-app illustrations go in `assets/illustrations/raster/` and the `AppIllustration`
  widget switches to `Image.asset` with the dark or light file by theme, with the SVGs kept as
  the fallback. That is a small change to `lib/ui/widgets/illustration.dart` and the
  illustration test, nothing else in the app moves.
* The banner replaces `docs/images/banner.svg` in the README.

The Android notification glyph stays a hand-drawn vector (`ic_stat_stone.xml`): Android
flattens small icons to a white silhouette, so a painted image would not survive there.

## Checking a result before you keep it

* Would it still read as a stone in water at 48 px? If not, simplify.
* Is anything touching the edges, or outside the central 66 % on the icon? Regenerate.
* Any text, face, sparkle, glow or star that crept in? Regenerate; do not crop around it.
* Do the dark and light variants have the same composition? They should overlay exactly.
* Does the set look like one series when the eight are placed side by side?
