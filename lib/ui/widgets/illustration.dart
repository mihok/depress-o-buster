import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

/// Every illustration in the app, by the file that draws it.
///
/// The files live in `assets/illustrations/` and follow the contract in
/// `docs/VISUALS.md`: one stone-and-water motif, authored for the dark theme in
/// six palette colours that [PaletteMapper] swaps for the light theme at
/// runtime. Replace an SVG with the same name and nothing else changes.
enum Illustration {
  /// One stone in still water. The Start tab, above the one-tap button.
  stoneStill('stone_still', 'A stone resting in still water'),

  /// The stone with soft light on the horizon. After a quiet stretch, and
  /// when a rest completes.
  stoneDawn('stone_dawn', 'A stone in still water with soft light on the horizon'),

  /// A near stone and two further ones. The running approach.
  pathAhead('path_ahead', 'Stepping stones leading away across still water'),

  /// A thin moon over water, no stone. The running rest.
  restMoon('rest_moon', 'A thin moon over still water'),

  /// The stone with rings spreading from it. An approach just completed.
  rippleDone('ripple_done', 'A stone with rings spreading from it'),

  /// Three small stones in a loose line. The Tasks tab with no tasks.
  stonesEmpty('stones_empty', 'Three small stones in a line across water'),

  /// Water only. Empty history and progress.
  waterQuiet('water_quiet', 'Still water with one faint ring'),

  /// A stone above three pebbles. The "break this down smaller" sheet.
  stoneSplit('stone_split', 'A stone above three smaller pebbles'),

  /// The brand mark, with its own background. Fixed colours in both themes.
  mark('mark', 'The Depress-o-buster mark: a stone in still water', folder: 'brand');

  const Illustration(this.file, this.description, {this.folder = 'illustrations'});

  final String file;
  final String description;
  final String folder;

  String get assetPath => 'assets/$folder/$file.svg';

  /// The mark carries its own background, so it keeps the brand colours
  /// whatever the theme. Everything else follows the theme.
  bool get followsTheme => this != Illustration.mark;
}

/// Swaps the dark-theme authoring palette for the light theme's.
///
/// Colours are matched by exact value, so an SVG must use only the six
/// palette values from `docs/VISUALS.md`. Opacity attributes pass through.
class PaletteMapper extends ColorMapper {
  const PaletteMapper._(this._map);

  static const PaletteMapper light = PaletteMapper._({
    0xFF8FB39A: Color(0xFF4E7A5C), // stone
    0xFF8E9BC7: Color(0xFF59689E), // water
    0xFFE6E8EA: Color(0xFF23272B), // ink
    0xFF9AA3AB: Color(0xFF5F6B74), // muted
    0xFF1F2328: Color(0xFFE9E7E1), // surface
    0xFF0F1114: Color(0xFFF4F3EF), // background
    // #FFFFFF (glint) is deliberately absent: a highlight stays light in both themes.
  });

  /// The dark palette is the one the files are authored in, so nothing moves.
  static const PaletteMapper dark = PaletteMapper._({});

  static PaletteMapper of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  final Map<int, Color> _map;

  @override
  Color substitute(String? id, String elementName, String attributeName, Color color) {
    return _map[color.toARGB32()] ?? color;
  }
}

/// One of the app's illustrations, sized by height and coloured by the theme.
///
/// Illustrations are decorative: the text beside them carries the meaning,
/// so they are hidden from assistive technology unless [decorative] is false.
class AppIllustration extends StatelessWidget {
  const AppIllustration(
    this.kind, {
    super.key,
    this.height = 132,
    this.opacity = 1,
    this.decorative = true,
  });

  final Illustration kind;
  final double height;
  final double opacity;
  final bool decorative;

  @override
  Widget build(BuildContext context) {
    final picture = SvgPicture.asset(
      kind.assetPath,
      height: height,
      fit: BoxFit.contain,
      colorMapper: kind.followsTheme ? PaletteMapper.of(context) : null,
      excludeFromSemantics: decorative,
      semanticsLabel: decorative ? null : kind.description,
      // Keep the layout stable while the asset decodes.
      placeholderBuilder: (_) => SizedBox(height: height),
    );
    final faded = opacity >= 1 ? picture : Opacity(opacity: opacity, child: picture);
    return Center(child: faded);
  }
}

/// A short phrase under an illustration in an empty state, in the muted style.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    this.body,
    this.action,
  });

  final Illustration illustration;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIllustration(illustration, height: 120),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: theme.textTheme.bodySmall),
          ],
          if (action != null) ...[
            const SizedBox(height: 20),
            action!,
          ],
        ],
      ),
    );
  }
}

/// The colours the procedural widgets share with the illustrations.
class IllustrationColors {
  IllustrationColors._();

  static Color stone(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.approach : const Color(0xFF4E7A5C);

  static Color water(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.rest : const Color(0xFF59689E);

  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? AppColors.darkMuted : AppColors.lightMuted;
}
