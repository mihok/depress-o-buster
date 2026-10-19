import 'package:flutter/material.dart';

import 'illustration.dart';

/// The level badge: a cairn of stacked stones that grows one stone per level.
///
/// Level 1 is a single stone lying flat. Each level adds a stone until nine,
/// then the cairn is complete and stays. It never loses a stone, which is the
/// visual form of the XP rules: nothing is taken back.
class Cairn extends StatelessWidget {
  const Cairn({super.key, required this.level, this.size = const Size(84, 104)});

  final int level;
  final Size size;

  static const int maxStones = 9;

  int get stones => level.clamp(1, maxStones);

  @override
  Widget build(BuildContext context) {
    final count = stones;
    return Semantics(
      label: 'Level $level cairn, $count ${count == 1 ? 'stone' : 'stones'}',
      child: CustomPaint(
        size: size,
        painter: CairnPainter(
          stones: count,
          stone: IllustrationColors.stone(context),
          muted: IllustrationColors.muted(context),
          water: IllustrationColors.water(context),
        ),
      ),
    );
  }
}

/// Draws [stones] pebbles stacked on a water line. Pure and deterministic, so
/// the same level always paints the same cairn.
class CairnPainter extends CustomPainter {
  const CairnPainter({
    required this.stones,
    required this.stone,
    required this.muted,
    required this.water,
  });

  final int stones;
  final Color stone;
  final Color muted;
  final Color water;

  @override
  void paint(Canvas canvas, Size size) {
    final n = stones.clamp(1, Cairn.maxStones);
    final waterY = size.height * 0.88;

    // The water line the cairn stands on, a little wider than the base.
    final linePaint = Paint()
      ..color = water.withValues(alpha: 0.45)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.04, waterY + 3),
      Offset(size.width * 0.96, waterY + 3),
      linePaint,
    );

    // Stone heights: a short cairn uses taller stones; a tall one uses thinner
    // ones so nine still fit. Widths narrow toward the top.
    final available = size.height * 0.82;
    final stoneHeight = (available / (n < 4 ? 4 : n)).clamp(6.0, size.height * 0.3);
    final overlap = stoneHeight * 0.18; // stones settle into each other a little
    var baseline = waterY;
    for (var i = 0; i < n; i++) {
      final t = n == 1 ? 0.0 : i / (n - 1);
      final width = size.width * (0.92 - 0.5 * t);
      final height = stoneHeight * (1 - 0.12 * t);
      // Deterministic sideways settle so the stack is not a perfect column.
      final drift = ((i * 7) % 5 - 2) * size.width * 0.018;
      final left = (size.width - width) / 2 + drift;
      final top = baseline - height;
      final isTop = i == n - 1;
      final paint = Paint()
        ..color = isTop
            ? stone
            : muted.withValues(alpha: 0.55 + 0.35 * (i / n));
      canvas.drawPath(_pebble(Rect.fromLTWH(left, top, width, height)), paint);
      baseline = top + overlap;
    }
  }

  /// The same silhouette as the brand mark: rounded, slightly flatter below.
  static Path _pebble(Rect r) {
    final w = r.width;
    final h = r.height;
    final x = r.left;
    final y = r.top;
    return Path()
      ..moveTo(x, y + h * 0.55)
      ..cubicTo(x, y + h * 0.18, x + w * 0.22, y, x + w * 0.52, y)
      ..cubicTo(x + w * 0.8, y, x + w, y + h * 0.2, x + w, y + h * 0.55)
      ..cubicTo(x + w, y + h * 0.85, x + w * 0.78, y + h, x + w * 0.5, y + h)
      ..cubicTo(x + w * 0.2, y + h, x, y + h * 0.85, x, y + h * 0.55)
      ..close();
  }

  @override
  bool shouldRepaint(CairnPainter old) =>
      old.stones != stones || old.stone != stone || old.muted != muted || old.water != water;
}
