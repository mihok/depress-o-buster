import 'package:flutter/material.dart';

import 'illustration.dart';

/// One slow ring that spreads and fades behind [child] when [trigger] changes.
///
/// This is the whole celebration: a single ripple, 1.8 seconds, never above
/// 35 % opacity. It plays once per distinct [trigger] value and not at all
/// when the platform asks for reduced motion. Null triggers never play.
class RippleCelebration extends StatefulWidget {
  const RippleCelebration({super.key, required this.trigger, required this.child});

  final Object? trigger;
  final Widget child;

  static const Duration duration = Duration(milliseconds: 1800);

  @override
  State<RippleCelebration> createState() => _RippleCelebrationState();
}

class _RippleCelebrationState extends State<RippleCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: RippleCelebration.duration);
  Object? _played;

  @override
  void initState() {
    super.initState();
    _maybePlay();
  }

  @override
  void didUpdateWidget(RippleCelebration old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) _maybePlay();
  }

  void _maybePlay() {
    final t = widget.trigger;
    if (t == null || t == _played) return;
    _played = t;
    // Reduced motion is honoured at the moment of the trigger.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      _controller.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: RipplePainter(
                  progress: _controller.value,
                  color: IllustrationColors.water(context),
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// A single elliptical ring that grows from the centre and fades out.
class RipplePainter extends CustomPainter {
  const RipplePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final eased = Curves.easeOut.transform(progress);
    final alpha = 0.35 * (1 - eased);
    final rx = size.width * (0.12 + 0.48 * eased);
    final ry = size.height * (0.25 + 0.75 * eased);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: alpha);
    canvas.drawOval(
      Rect.fromCenter(center: size.center(Offset.zero), width: rx * 2, height: ry * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(RipplePainter old) => old.progress != progress || old.color != color;
}
