# Image prompts for Kara AI

Everything the app shows is one metaphor: a **stone** is one small step, **still water** is
rest, and progress is a **cairn** that only grows. These prompts produce the production
versions of every image slot in that language.

A text-to-image model does not remember its last output, so "the same stone as before"
means nothing to it. The pack therefore generates as little as possible and derives the
rest: one master mark, one master illustration, and every other file by placing, scaling,
recolouring or erasing in an editor. The Pipeline section says which is which. Read it
before pasting anything.

## Style block (paste every time)

Every prompt has the same shape: one to four sentences that describe the slot, then the
POSITIVE block pasted verbatim. The slot sentences come first because the model weights the
start of a prompt most. The NEGATIVE block goes in the tool's negative-prompt field only,
plus the one-line slot negative under each prompt. If the tool has no negative field, do
not paste the NEGATIVE list anywhere; instead end each prompt with one affirmative
sentence: "The rest of the frame is plain, empty background."

```
POSITIVE (after the slot sentences, in every prompt)

STYLE: Flat vector illustration, like an app empty-state illustration exported from a
design tool: solid even fills, clean crisp edges, muted desaturated colours, large empty
margins around one subject. Stones are solid filled shapes; water lines are thin stroked
lines with nothing inside them. The only shading anywhere is one soft pale oval highlight
on the upper left of the main stone. Nothing is in the scene but the stones, the water
lines and the light the prompt names.

GEOMETRY: The camera is low, just above the water, so every ring on the water is a flat
ellipse about four to five times wider than tall and the stone's underside is hidden at the
water line. The stone is one smooth pebble about five units wide to three tall, rounded
top, slightly flatter base, its base exactly on the water line. Rings are thin, even lines
about one hundredth of the image width thick, centred on the stone's base; the back half
of each ring passes behind the stone. The horizon is one thin line at the water level,
shorter than the frame and fainter than the rings. The water is never painted as a filled
area: it is shown only by the ring lines and the horizon line, and the plain background
shows through everywhere else, above and below the water line alike. Everything is flat
colour.
```

```
NEGATIVE (negative-prompt field only)

text, letters, numbers, logos, watermarks, people, hands, faces, animals, fish, birds,
characters, eyes on objects, arrows, checkmarks, ticks, trophies, medals, ribbons, flags,
crowns, exclamation marks, speed lines, motion lines, splash, waves, water drop, droplet,
raindrop, ripple, concentric circles, reflection, mirror image, lake, pond, filled water,
water surface, sky, sky gradient, sunrise, sunset, sun, sun rays, clouds, mist, fog, haze,
horizon landscape, sparkles, stars, confetti, sunburst, lens flare, glow, halo, neon,
orange, pink, high saturation, zen garden, raked sand, gravel, grass, moss, bonsai, reeds,
lily pad, lotus, bamboo, hill, mountain, tree, landscape, boat, lantern, candle, incense,
spa, wellness, stacked stones, cairn, pile, stack, extra stones, cast shadow, harsh
shadows, shading, gradient background, texture, grain, noise, film grain, speckles,
cracks, outline, stroke around stone, blur, bokeh, depth of field, glossy 3D render,
photo, photograph, photorealism, busy background, border, frame, vignette, drop shadow,
checkerboard, transparency grid, app icon mockup, rounded square, squircle, phone, device,
screen, interior, furniture
```

## Palette

Name colours in a prompt exactly as this table does, with the hex after the name: some
models honour the hex, the rest fall back to the name. A prompt names at most three of
these; the background colour is the only other colour in the image. Dark is what you
generate. Light is made from the dark file by palette swap (see Pipeline), never by a
second generation.

| Role                     | Dark (generate with this)                       | Light (swap to this)         |
|--------------------------|-------------------------------------------------|------------------------------|
| stone                    | soft sage green `#8FB39A` (a greyed, calm green) | deep sage green `#4E7A5C`    |
| water lines              | muted periwinkle blue-grey `#8E9BC7`            | deep slate blue `#59689E`    |
| soft light               | pale grey `#E6E8EA`                             | near-black grey `#23272B`    |
| other stones             | mid grey `#9AA3AB`                              | dark slate grey `#5F6B74`    |
| background               | plain flat charcoal `#0F1114`                   | plain flat off-white `#F4F3EF` |
| sheet surface (`stone_split` only) | `#171A1E`                             | `#FFFFFF`                    |

Opacity means nothing to the model without a known background, so the prompts say
"clearly visible", "about half as strong" and "half faded into the background" instead of
percentages. The depth rule is the app's own: the nearest thing is at full strength, the
farthest is faint.

## Sizes and backgrounds at a glance

Sizes and aspect ratios go in the tool's size setting, not in the prompt text: the model
does not measure, and numerals in a prompt can come back as painted digits. Generate at the
nearest supported aspect (1:1, 3:2 or 2:1) and crop or resize to the sizes here.

| Slot                        | Hand-back file                        | Hand-back size (px)                                   | Background            | Made by                                              |
|-----------------------------|---------------------------------------|-------------------------------------------------------|-----------------------|------------------------------------------------------|
| App icon                    | `mark.png`                            | 1024 × 1024                                           | Charcoal, flat        | Generated: the master mark (1)                       |
| App icon, foreground        | `mark_foreground.png`                 | 1024 × 1024                                           | Transparent           | Master scaled into a 626 px circle (1b)              |
| App icon, monochrome        | `mark_mono.png`                       | 1024 × 1024                                           | Transparent           | Foreground thresholded to white (1c)                 |
| App icon, transparent       | `mark_transparent.png`                | 1024 × 1024                                           | Transparent           | Master at icon scale, charcoal removed (1d)          |
| Splash mark                 | `splash_mark.png`                     | 640 × 640                                             | Transparent           | Master downsampled (2)                               |
| Splash, Android 12+         | `splash_android12.png`                | 1152 × 1152                                           | Transparent           | Foreground padded (2b)                               |
| In-app illustrations ×8     | `<name>_dark.png`, `<name>_light.png` | Master 1440 × 960; ship 240 × 160, 480 × 320, 720 × 480 | Transparent           | 3a generated, 3b to 3h by reference, light by swap   |
| Cairn badges ×9, optional   | `cairn_<n>_dark.png`, `_light.png`    | 600 × 720                                             | Transparent           | One generation of nine stones, erased down (4)       |
| README banner               | `banner.png`                          | 1600 × 480                                            | Charcoal, flat        | Master placed in an editor (5)                       |
| Store feature graphic       | `feature_graphic.png`                 | 1024 × 500                                            | Charcoal, flat, no alpha | Generated at 2:1 and cropped (6)                  |

**Transparency.** Switch on the tool's transparent or alpha output, or its
background-removal option, if it has one. In the prompt itself always name a solid colour:
dark variants on a plain, perfectly flat, untextured charcoal `#0F1114` background; light
variants on a plain, perfectly flat, untextured off-white `#F4F3EF` background. Never write
"transparent background" in a prompt; most generators paint a checkerboard or a grey plate
when they read it.

If the tool cannot output true alpha: (1) generate dark variants on flat charcoal
`#0F1114` and light variants on flat off-white `#F4F3EF`, with no grain or texture; (2) do
not key them; hand them over opaque and the app will place each on exactly that colour;
(3) `stone_split` sits on the bottom-sheet surface, not the page background, so generate it
on `#171A1E` (dark) and `#FFFFFF` (light), or tell us and we will move it onto the page
background in code. A colour key does not work on this art: the rings are half faded into
the background, so a key leaves tinted halos and hard edges. Keying is acceptable only for
the monochrome mark, where every pixel is either white or background.

The master mark needs alpha more than anything else, because four of its derived files are
transparent. If alpha is impossible there, the opaque icon, the banner and the feature
graphic still come from the master; for the foreground, the transparent icon and both
splash files either cut the charcoal away by hand in an editor (the mark is one solid
shape and two thin lines, so a careful manual cut is feasible where a key is not) or keep
today's vector-derived PNGs for those four slots and tell us.

## Pipeline

Generate three things. Derive everything else.

1. **The master mark.** Generate the app icon (1) with alpha on, or on flat charcoal. Lock
   the seed and keep the file. The icon, foreground, monochrome, transparent icon, both
   splash files and the banner's left third are made from this one file by placing and
   scaling it in an editor, never by regenerating.
2. **The master illustration.** Generate `stone_still` (3a) first. Then make 3b, 3c, 3e,
   3f and 3h by feeding 3a's output as the reference image (image-to-image at low
   strength, or the tool's reference or style-reference feature) with the same seed and the
   slot prompt. 3d (`rest_moon`) has no stone, so give it 3a as a style reference only.
   3g (`water_quiet`) is 3a with the stone erased.
3. **The cairn**, only if wanted: one image of nine stones, erased down to eight, seven and
   so on (4).

Light variants are never generated. Make every light file from its dark PNG by a flat
palette swap in an editor (the Palette table, background included), or with the tool's
image-to-image or recolour mode using the dark PNG as the reference and the instruction
"identical composition, only these colour substitutions". Dark and light must overlay
exactly; that is how the app switches theme without the picture jumping. If a light prompt
is ever needed as a last resort, take the dark prompt and replace every colour name and hex
with its light counterpart from the Palette table, the background sentence included.

## 1. App icon (the master mark)

Shown on the home screen at 48 to 60 px, so it must read as one shape. The art spans about
three quarters of the width, centred; iOS only rounds the corners, so keep the outer tenth
clear of anything important. Set the tool to 1:1 at 1024.

```
A square image, edge-to-edge plain flat charcoal #0F1114, with nothing touching the edges.
One smooth pebble in soft sage green #8FB39A, about five wide to three tall, its base a
little below the centre of the square. Around its base, two thin elliptical ring lines in
muted periwinkle blue-grey #8E9BC7: the inner one clearly visible, the outer one larger and
about half as strong, as if half faded into the charcoal, each passing behind the stone.
One soft pale oval highlight on the stone's upper left. The charcoal background is the
water; the two thin rings are the only sign of it. The whole mark spans about three
quarters of the width, with empty charcoal on every side.

[POSITIVE]
```

Slot negative: app icon mockup, rounded square, squircle, phone, device, screen, bevel,
border, frame, drop shadow

### 1b. App icon, foreground only

Not generated. Take the master with alpha and scale the composition down so all artwork
sits inside a centred circle 626 px across (61 % of the 1024 px width); the corners of the
canvas must be empty. Android crops the outer 16.7 % on every side and may mask the rest
to a circle.

### 1c. App icon, monochrome silhouette

Not generated. Android 13 themed icons and the notification shade need one flat shape that
matches the painted icon exactly. Threshold or trace the alpha of 1b to pure white
`#FFFFFF` on transparent, 1024 × 1024: the stone as a solid shape, the two rings as thin
lines, inside the same 626 px circle. Keep `assets/brand/mark_mono.svg` as is if the trace is rough.

### 1d. App icon, transparent

Not generated. The master at exactly the icon's scale and placement, 1024 × 1024, with the
charcoal removed and nothing moved. It feeds the iOS 18 dark and tinted icons; the
generator desaturates the tinted one itself.

## 2. Splash mark

Not generated. Shown alone on a charcoal (dark) or off-white (light) screen for about a
second. It is the master on transparent, scaled so the artwork spans about 70 % of the
width, centred. Work at 1024 for quality, then downsample the hand-back:
flutter_native_splash divides this image by 4 to get dp, so 1024 px would show at 256 dp.
Hand back 640 × 640 (160 dp, matching today's `splash_mark.png`) or 768 × 768 (192 dp).
If it must be a generation, use the icon prompt with "the whole mark spans most of the
width" and alpha on.

### 2b. Splash, Android 12+

Not generated. Pad `mark_foreground.png` (1024 px, art inside 626 px) to 1152 × 1152,
centred, on transparent. All artwork then sits inside the centred 768 px circle that
Android clips this image to; today's `splash_android12.svg` is built exactly this way.

## 3. In-app illustrations

All eight share one framing. Set the tool to 3:2 and generate at 1440 × 960. One subject,
centred or just left of centre, with a wide empty margin on every side. The water line sits
about two thirds of the way down the frame. Viewpoint, the same in all eight: low and just
above the water, as if sitting on the bank. The main stone is the same object as the app
icon, about a quarter of the frame width, and sits in the same place in every image that
has it. Generate only the dark variant, on flat charcoal, with alpha on where the tool has
it. The Pipeline says how 3b to 3h come from 3a and how the light variants are made.

Shipped sizes: each variant goes into `assets/illustrations/raster/` three times under the
same filename, 240 × 160 at the root (1x, the SVG viewBox), 480 × 320 in `2.0x/`,
720 × 480 in `3.0x/`. Flutter picks the nearest density itself; the 1440 × 960 master is
not shipped. If one file per variant is simpler, ship 720 × 480 at the root only: Flutter
treats it as 1x and scales it down, and it stays sharp on 3x screens.

### 3a. `stone_still` (Start screen)

What it says: nothing is required of you.

```
One smooth pebble in soft sage green #8FB39A resting on the water line, a little left of
centre, on a plain flat charcoal #0F1114 background. One thin elliptical ring line in muted
periwinkle blue-grey #8E9BC7 around its base, faint, as if half faded into the charcoal,
its back half hidden behind the stone. To the right of the stone, one short, fainter
horizon line at the water level. Those three marks are the whole image, with wide empty
charcoal on every side.

[POSITIVE]
```

Slot negative: second stone, extra stones, reflection

### 3b. `stone_dawn` (Start screen after a few quiet days; rest complete)

What it says: good to see you.

```
The stone from stone_still, same size and place: one smooth pebble in soft sage green
#8FB39A on the water line, a little left of centre, on a plain flat charcoal #0F1114
background, with one faint thin ring line in muted periwinkle blue-grey #8E9BC7 around its
base. Behind the stone, a very faint, soft-edged dome of pale grey #E6E8EA light sits on
the water line, brightest at the line and fading to nothing before the top of the frame,
its edge too soft to see; the space above stays empty charcoal. On the water below the
ring, two short, soft horizontal pale strokes. The light is pale grey only, like an
overcast morning. Quiet and unhurried.

[POSITIVE]
```

Slot negative: sun, sun disc, rays, sunrise, sunset, orange, yellow, warm light, lens
flare, reflection path, hill, mountain, clouds

The palette swap turns the dome near-black grey `#23272B` at the same low strength, so in
light mode it reads as soft morning haze on the water, not a shadow behind the stone.

### 3c. `path_ahead` (The running approach timer)

What it says: being near the thing, one stone at a time.

```
Exactly three separate pebbles with open charcoal between them, each on its own thin ring
line in muted periwinkle blue-grey #8E9BC7, on a plain flat charcoal #0F1114 background.
The nearest is the stone from stone_still, in soft sage green #8FB39A, at full strength, a
little left of centre on the water line; it is the subject. The second, in mid grey
#9AA3AB, is smaller and fainter, near the middle and further back. The third, also mid
grey, is smaller and fainter still, at the upper right, half faded into the charcoal. The
stones recede across flat water in perspective: the far stones are smaller and higher only
because they are further away, and the farthest fades into the background. The stones
themselves form the path, with open background between them.

[POSITIVE]
```

Slot negative: path, footpath, flagstones, grass, moss, stream, bridge, footprints,
arrows, many stones, pile, stack, far shore, bank, gate, destination, light at the end,
line in the water

### 3d. `rest_moon` (The running rest timer)

What it says: rest is part of the method; there is nothing to approach.

```
A thin crescent in muted periwinkle blue-grey #8E9BC7, solid flat fill, its horns pointing
left and slightly upward, about a quarter of its diameter thick, high and a little right of
centre on a plain flat charcoal #0F1114 background. The space around it is empty charcoal.
On the water below it, one short, soft horizontal stroke of the same colour, fainter than
the crescent, and a thin horizon line. Those three marks are the whole image.

[POSITIVE]
```

Slot negative: stars, night sky, clouds, moon face, craters, full moon, glow, halo,
reflection, light path, sky gradient, stone

### 3e. `ripple_done` (Approach complete)

What it says: that counted.

```
The stone from stone_still, same size and place, sitting still on flat water with its base
a hair above the water line: one smooth pebble in soft sage green #8FB39A, a little left of
centre, on a plain flat charcoal #0F1114 background. Around its base, two calm elliptical
ring lines in muted periwinkle blue-grey #8E9BC7, one inside the other: the inner ring
clearly visible, the outer ring twice as wide and about half as strong. The back half of
each ring passes behind the stone. Only the two rings are new; the water has simply
noticed.

[POSITIVE]
```

Slot negative: splash, droplet, water drop, crown splash, raindrop, concentric circles,
motion, waves, falling, floating

### 3f. `stones_empty` (Tasks screen with no tasks)

What it says: pick one up.

```
Exactly three small separate pebbles, all the same mid grey #9AA3AB, each about two thirds
the size of the stone in stone_still, with open charcoal between them, on a plain flat
charcoal #0F1114 background. They sit in a loose line that bends: the nearest at the lower
left on the water line, at full strength; the middle a little right of centre and further
back, fainter; the farthest smaller, higher and back toward the centre, fainter still,
half faded into the charcoal. Each rests on its own thin ring line in muted periwinkle
blue-grey #8E9BC7, and a short horizon line sits at the water level. The three stones
simply rest where they are.

[POSITIVE]
```

Slot negative: green, sage, path, footpath, arrows, many stones, pile, stack

### 3g. `water_quiet` (Empty history and empty progress)

What it says: nothing logged yet, and that is fine.

Not generated. Erase the stone from 3a's output, leaving the ring and the horizon line;
that also guarantees it is the same series. If it must be generated:

```
One thin elliptical ring line in muted periwinkle blue-grey #8E9BC7, a little left of
centre on the water line, and a short thin horizon line to its right, on a plain flat
charcoal #0F1114 background. Those two marks are the entire image.

[POSITIVE]
```

Slot negative: stone, pebble, moon, light, mist, landscape

### 3h. `stone_split` ("Break this down smaller" sheet)

What it says: smaller is still a step.

Shown at 72 px tall beside the sheet title, so every shape stays large and simple. This
slot sits on the sheet surface: without alpha, generate it on `#171A1E` instead of
charcoal.

```
One pebble in soft sage green #8FB39A, the stone from stone_still, held still in the empty
upper half of the frame, centred, with plain charcoal around it and beneath it: it is
simply set aside, waiting. Below, resting on the water line, three much smaller pebbles of
the same sage, each about a third of its size, spaced evenly across the width, each on its
own thin ring line in muted periwinkle blue-grey #8E9BC7; the left one at full strength,
the middle a little fainter, the right fainter still. The three small pebbles are the
subject. Open charcoal between the upper stone and the pebbles, on a plain flat charcoal
#0F1114 background.

[POSITIVE]
```

Slot negative: shadow, motion blur, falling, dropping, arrow, line, connector, ring under
the upper stone, reflection

## 4. Cairn badges (optional, nine images)

The level badge is drawn in code today (`lib/ui/widgets/cairn.dart`) and does not need
these. Not wired: using painted badges would mean a new asset folder entry in
`pubspec.yaml` and a rewrite of the `Cairn` widget, so skip them unless that work is
planned.

If you do want them, generate one image of nine stones and derive the other eight from it,
so the nine overlay exactly and the badge visibly grows in place from level to level. Set
the tool to 5:6 (or 1:1 and crop) at 600 × 720. Remove "stacked stones, cairn, pile,
stack" from the negative field for this slot only.

```
A tall stack of exactly nine smooth pebbles standing on one thin horizontal water line near
the bottom of a plain flat charcoal #0F1114 background. The bottom stone is wide and low,
nearly the full width of the frame; each stone above is a little narrower, the top stone
about half the width of the base; the stack reaches almost to the top of the frame and
settles very slightly off a perfect column. Only the top stone is soft sage green #8FB39A.
The eight below are mid grey #9AA3AB, the lowest faintest, as if half faded into the
charcoal, and each one above a little stronger. Flat colour throughout.

[POSITIVE]
```

Slot negative: beach, sand, sea, sky, photo, photograph, realistic, scattered pebbles,
shadow, highlight

Then make `cairn_8` down to `cairn_1` from that file, not from new prompts: erase the
stones above N and recolour the new top stone sage. If Kara AI takes a reference image,
feed `cairn_9` and ask for "the same cairn, same position and sizes, only the bottom N
stones, the Nth stone in sage". For N = 1 the single stone is the base stone, in sage.
Keep the empty space above; do not recentre or rescale. Light variants by palette swap,
as everywhere.

## 5. README banner

Not generated. Set up a 1600 × 480 canvas of flat charcoal `#0F1114` in an editor and place
the master mark (with alpha) in the left third. Draw one thin horizon line in muted
periwinkle blue-grey `#8E9BC7` from the stone toward the right edge, fading out, fainter
than the rings. The right two thirds are plain, uninterrupted charcoal. Save as
`docs/images/banner.png` and change the README image link from `banner.svg` to
`banner.png`; the SVG can be deleted.

If it must be a generation, set the tool to its widest supported aspect and crop to
1600 × 480:

```
One smooth pebble in soft sage green #8FB39A on the water line in the left third of a very
wide, plain flat charcoal #0F1114 image, with two thin elliptical ring lines in muted
periwinkle blue-grey #8E9BC7 around its base, the inner clearly visible and the outer
larger and half as strong, each passing behind the stone. One thin horizon line of the same
colour runs from the stone toward the right edge and fades out. The right two thirds are
plain, uninterrupted charcoal.

[POSITIVE]
```

Slot negative: text, title, lettering, typography, words, logo, watermark

## 6. Store feature graphic (Google Play)

Set the tool to 2:1 and crop to exactly 1024 × 500. Export as 24-bit PNG or JPEG with no
alpha channel; Google Play rejects a feature graphic that has one.

```
Exactly four separate pebbles with open charcoal between them, each on its own thin ring
line in muted periwinkle blue-grey #8E9BC7, on a plain flat charcoal #0F1114 background.
The nearest, in soft sage green #8FB39A, sits at the lower left at full strength; the other
three, in mid grey #9AA3AB, are each smaller and fainter, receding toward the right across
flat water in perspective, the farthest half faded into the charcoal. The far stones are
smaller and higher only because they are further away. A thin horizon line of the
periwinkle colour at the water level. The upper left quarter is plain, uninterrupted
charcoal.

[POSITIVE]
```

Slot negative: text, title, lettering, typography, words, logo, watermark, path,
footpath, far shore, bank, gate, destination, light at the end, many stones, pile, stack

## Handing the files back

Put everything in one folder with these names. The left column is what you send; the right
column is where it lands. The `pubspec.yaml` keys stay unchanged.

```
mark.png              -> assets/brand/mark.png              (1, the opaque icon)
mark_foreground.png   -> assets/brand/mark_foreground.png   (1b)
mark_mono.png         -> assets/brand/mark_mono.png         (1c)
mark_transparent.png  -> assets/brand/mark_transparent.png  (1d, iOS 18 dark and tinted)
splash_mark.png       -> assets/brand/splash_mark.png       (2, 640 or 768 px)
splash_android12.png  -> assets/brand/splash_android12.png  (2b, 1152 px)
<name>_dark.png and <name>_light.png for the eight illustrations, at 240 x 160, 480 x 320
and 720 x 480       -> assets/illustrations/raster/, raster/2.0x/, raster/3.0x/
banner.png            -> docs/images/banner.png
feature_graphic.png   -> the Play Console, not the repo
cairn_1_dark.png ... cairn_9_light.png, optional, not wired
```

PNG, sRGB, transparent where the table says so, or on the declared flat colour if alpha
was impossible. Then the wiring:

* The brand PNGs replace the ones in `assets/brand/` and the generators are re-run
  (`dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, see
  `docs/VISUALS.md`). The painted PNGs become the source of truth: remove the rasterise
  step from `docs/VISUALS.md`, since `node tool/brand/rasterize.js` would overwrite them on
  its next run, and keep `tool/brand/build_brand.py` only as the record of the vector mark
  the painted one replaced.
* The About row in Settings shows the mark at 56 px (`Illustration.mark` →
  `assets/brand/mark.svg`, with its own charcoal background, clipped to a 14 px radius).
  Point it at `mark.png` (an `Image.asset` branch for `Illustration.mark` in
  `AppIllustration`, or replace `mark.svg` with an SVG that wraps the raster) so the About
  row and the home-screen icon are the same picture. Check it at 56 px on both themes; the
  charcoal square on the off-white card in light mode is intended.
* `pubspec.yaml` gets a new entry `- assets/illustrations/raster/` under `flutter.assets`.
  Flutter bundles only the files directly in a declared folder, and picks up the `2.0x/`
  and `3.0x/` subfolders as density variants automatically.
* `lib/ui/widgets/illustration.dart`: add
  `String rasterPath(Brightness b) => 'assets/illustrations/raster/${file}_${b == Brightness.dark ? 'dark' : 'light'}.png'`
  to the enum; in `AppIllustration` use
  `Image.asset(kind.rasterPath(brightness), height: height, fit: BoxFit.contain, excludeFromSemantics: decorative, semanticLabel: decorative ? null : kind.description, errorBuilder: (...) => <the existing SvgPicture>)`
  for `followsTheme` kinds, and keep the mark on `SvgPicture` unless the About row change
  above is made. In the illustration test, keep the SVG contract group for the fallbacks,
  add an exists check for each raster file in both variants, and change the render
  assertion to count `Image` for themed kinds plus one `SvgPicture` for the mark.
* The README image link changes from `banner.svg` to `banner.png`.
* Play Console hi-res icon: `mark.png` downscaled to 512 × 512 (32-bit PNG). The App Store
  marketing icon is generated from `mark.png` by flutter_launcher_icons.

The Android notification glyph stays a hand-drawn vector (`ic_stat_stone.xml`): Android
flattens small icons to a white silhouette, so a painted image would not survive there.

## Checking a result before you keep it

* Would it still read as a stone in water at 48 px? If not, simplify.
* Is anything touching the edges, or outside the three-quarter width on the icon?
  Regenerate.
* Is the water a filled area, a reflection, a sky or a sand garden? Regenerate; the water
  is only lines.
* Any text, face, sparkle, glow, star or checkerboard that crept in? Regenerate; do not
  crop around it.
* Do the dark and light variants overlay exactly? They must: the light one is a recolour
  of the dark file, never a second generation.
* Does the set look like one series when the eight are placed side by side? Same stone,
  same place, same viewpoint.
* Does it ask anything of you? If a stone points somewhere, a path leads somewhere, a
  light glows, or anything looks like a reward, regenerate. The image should be fine to
  look at with no energy at all.
