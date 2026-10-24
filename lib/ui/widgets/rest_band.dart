import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/format.dart';

/// The rest that goes with a step, drawn as part of the step's card.
///
/// The band sits above the tile when the rest comes before the step and
/// below it otherwise, inside the same rounded card, so a long rest reads as
/// the card reaching out for it. Its height follows the rest on a log scale
/// ([heightFor]), so a ladder whose last rests are hours stays usable, and
/// one small pebble is drawn per rest unit ([units]), so the climb can be
/// counted as well as read. The words are kept so the number stays exact.
class RestBand extends StatelessWidget {
  const RestBand({
    super.key,
    required this.rest,
    required this.units,
    this.before = true,
  });

  /// The rest itself: the band's height and its words come from it.
  final Duration rest;

  /// How many rest units the rest is (the step's multiplier). One pebble each.
  final int units;

  /// Whether the rest comes before the step (the band is above the tile) or
  /// after it (below). Only the words for a screen reader change here.
  final bool before;

  /// The band never shrinks below one line of small text, and never grows
  /// past the height of a tile and a half, however long the rest.
  static const double minHeight = 18;
  static const double maxHeight = 104;

  /// Between the words and the first pebble.
  static const double _gap = 12;

  /// The band's height for a rest: 16 + 14 · log2(1 + minutes / 5), kept
  /// within [minHeight]..[maxHeight]. Doubling the rest adds a fixed amount
  /// once it is long, so 10 minutes is about 38, 20 about 48, 50 about 64
  /// and 2 hr 10 min about 83: still clearly taller each time, never a wall.
  static double heightFor(Duration rest) {
    final minutes = rest.inMilliseconds / Duration.millisecondsPerMinute;
    final raw = 16 + 14 * (math.log(1 + math.max(0, minutes) / 5) / math.ln2);
    return raw.clamp(minHeight, maxHeight);
  }

  /// "Rest 20 min", as the tile's subtitle used to say it.
  String get words => 'Rest ${formatWords(rest)}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      label: '$words ${before ? 'before' : 'after'} this step',
      excludeSemantics: true,
      child: SizedBox(
        height: heightFor(rest),
        child: ColoredBox(
          // Rest is the secondary colour everywhere in this app.
          color: scheme.secondaryContainer.withValues(alpha: 0.35),
          child: Padding(
            // The same inset as the tile's content, so the words line up
            // with the step's number.
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LayoutBuilder(
              builder: (context, constraints) => Row(
                children: [
                  // The words take the width they need and the pebbles the
                  // rest. A band too narrow even for the words fades them
                  // rather than spilling past its edge.
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: math.max(0, constraints.maxWidth - _gap)),
                    child: Text(
                      words,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: SizedBox.expand(
                      child: CustomPaint(painter: RestBandPainter(units: units, color: scheme.secondary)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One pebble per rest unit, on a gentle wave. Pure and deterministic: the
/// same count in the same space always draws the same pebbles.
///
/// Pebbles are laid in rows of as many as fit the width; a row that would
/// not fit the height is left out rather than drawn over the edge. Nothing is
/// allocated per frame beyond the one [Paint].
class RestBandPainter extends CustomPainter {
  const RestBandPainter({required this.units, required this.color});

  final int units;
  final Color color;

  static const double radius = 4;
  static const double spacing = 12;
  static const double rowPitch = 12;

  /// Six pebbles to a wave, a few pixels high: a ripple, not a bounce.
  static const double _wave = 2 * math.pi / 6;
  static const double _maxAmplitude = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (units <= 0 || size.width < 2 * radius || size.height < 2 * radius) return;
    final perRow = ((size.width - 2 * radius) / spacing).floor() + 1;
    final amplitude = math.min(_maxAmplitude, size.height / 2 - radius - 1).clamp(0.0, _maxAmplitude);
    final wanted = (units / perRow).ceil();
    final fit = ((size.height - 2 * radius - 2 * amplitude) / rowPitch).floor() + 1;
    final rows = math.min(wanted, math.max(1, fit));
    final top = size.height / 2 - (rows - 1) * rowPitch / 2;
    final paint = Paint()..color = color;
    var drawn = 0;
    for (var row = 0; row < rows && drawn < units; row++) {
      final cy = top + row * rowPitch;
      for (var i = 0; i < perRow && drawn < units; i++, drawn++) {
        final cx = radius + i * spacing;
        canvas.drawCircle(Offset(cx, cy + amplitude * math.sin(drawn * _wave)), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(RestBandPainter old) => old.units != units || old.color != color;
}
