import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A continuous slider for scaling a quantity by a factor.
///
/// The thumb maps linearly to `log(factor)`, so ×1 sits between the ends
/// where log(1) falls and equal drags multiply or divide equally. The factor
/// belongs to the parent: [onChanged] fires live while dragging, so it can
/// preview, and [onChangeEnd] once on release with the final factor.
///
/// The ends stretch. While the thumb is held within the outer 6 % of the
/// track, after 120 ms the bound on that side grows every 120 ms (the maximum
/// multiplies by 1.15, or the minimum divides by it) and the factor follows
/// the thumb, so it keeps growing or shrinking smoothly for as long as the
/// person holds. Moving back towards the middle stops the stretching and
/// pushing outward again resumes it; this follows the finger rather than the
/// thumb, which stays pinned at the end once the finger has gone past it,
/// with 12 px of slack so that tremor does not count. The widened range stays
/// until release, when it returns to [initialMin]..[initialMax] around
/// whatever factor the parent then holds (typically ×1 again). A single
/// release never goes past ×10 or below ×0.1.
class StretchSlider extends StatefulWidget {
  const StretchSlider({
    super.key,
    required this.factor,
    required this.onChanged,
    required this.onChangeEnd,
    this.initialMin = 0.25,
    this.initialMax = 4.0,
    this.leadingLabel = 'Shorter',
    this.trailingLabel = 'Longer',
    this.semanticsLabel,
  }) : assert(initialMin > 0 && initialMin < initialMax);

  /// The current factor, 1.0 meaning unchanged. Owned by the parent.
  final double factor;

  /// Called live while dragging, so the parent can preview.
  final ValueChanged<double> onChanged;

  /// Called once on release, with the final factor.
  final ValueChanged<double> onChangeEnd;

  /// The range shown before any stretching, and again after release.
  final double initialMin;
  final double initialMax;

  /// The short words at either end of the track.
  final String leadingLabel;
  final String trailingLabel;

  /// What a screen reader calls the slider.
  final String? semanticsLabel;

  @override
  State<StretchSlider> createState() => _StretchSliderState();
}

class _StretchSliderState extends State<StretchSlider> {
  // Per release. The control is relative, so a bigger change is another drag.
  static const double _floor = 0.1;
  static const double _ceiling = 10;
  static const double _edge = 0.06;
  static const double _growth = 1.15;
  static const Duration _tick = Duration(milliseconds: 120);

  /// How far the finger may wander back before it counts as pulling away:
  /// tremor is a few pixels, a change of mind is more.
  static const double _slack = 12;

  late double _lo = widget.initialMin;
  late double _hi = widget.initialMax;

  /// Where the thumb sits along the track, 0 at the left end, 1 at the right.
  double _t = 0.5;

  /// -1 while the minimum is stretching, 1 the maximum, 0 neither.
  int _side = 0;

  /// The last factor handed to [StretchSlider.onChanged] in this drag.
  double? _last;
  Timer? _timer;

  /// Pointer moves since the thumb was grabbed. Stretching needs a real
  /// drag, never the touch that grabbed the thumb.
  int _moves = 0;

  /// Where the thumb was grabbed, as a track fraction.
  double _grabT = 0.5;

  /// Between onChangeStart and onChangeEnd; only then do pointer moves count.
  bool _held = false;

  /// The pointer's x from the last down or move, with the maximum end on the
  /// right whatever the text direction, so outward is plus on either side.
  double _pointerX = 0;

  /// The outermost pointer x reached while stretching on [_side].
  double _farX = 0;

  /// The side where pulling back stopped the stretching, 0 when none. It
  /// holds until the thumb leaves that edge zone or the pointer pushes
  /// outward again.
  int _stoppedSide = 0;

  /// The innermost pointer x reached since that stop.
  double _nearX = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double _factorAt(double t) =>
      math.exp(math.log(_lo) + t * (math.log(_hi) - math.log(_lo)));

  void _emit(double factor) {
    _last = factor.clamp(_floor, _ceiling).toDouble();
    widget.onChanged(_last!);
  }

  void _handleStart(double logFactor) {
    _moves = 0;
    _held = true;
    _stoppedSide = 0;
    final span = math.log(_hi) - math.log(_lo);
    _grabT = span == 0 ? 0.5 : ((logFactor - math.log(_lo)) / span).clamp(0.0, 1.0).toDouble();
    _lo = math.min(widget.initialMin, widget.factor);
    _hi = math.max(widget.initialMax, widget.factor);
  }

  void _handleChanged(double logFactor) {
    final span = math.log(_hi) - math.log(_lo);
    _t = ((logFactor - math.log(_lo)) / span).clamp(0.0, 1.0).toDouble();
    if (!_held) {
      // A keyboard or screen-reader step arrives with no drag around it:
      // nothing holds and nothing will release, so it is one whole change,
      // never a stretch.
      _emit(_factorAt(_t));
      _handleEnd(logFactor);
      return;
    }
    _moves++;
    // Only the thumb can be dragged, so any change is a real move; the
    // guard keeps a grab that lands exactly on an end from stretching.
    final side = _moves >= 1 && _t != _grabT ? (_t >= 1 - _edge ? 1 : (_t <= _edge ? -1 : 0)) : 0;
    // Leaving the edge zone forgets a stop; while one holds, only the
    // pointer pushing outward again restarts the stretching.
    if (side != _stoppedSide) _stoppedSide = 0;
    if (side != _side && _stoppedSide == 0) _setSide(side);
    _emit(_factorAt(_t));
  }

  /// Starts stretching on [side], or stops it when [side] is 0.
  void _setSide(int side) {
    _timer?.cancel();
    _timer = null;
    _side = side;
    if (side != 0) {
      _farX = _pointerX;
      _timer = Timer.periodic(_tick, (_) => _stretch());
    }
  }

  /// The slider reports only clamped values and skips repeats, so once the
  /// finger is past the end of the track it goes quiet however the finger
  /// moves. The raw pointer still arrives here, and decides.
  void _handlePointer(PointerEvent event) {
    final x = event.position.dx;
    _pointerX = Directionality.of(context) == TextDirection.rtl ? -x : x;
    if (!_held) return;
    if (_side != 0) {
      final outward = _side * (_pointerX - _farX);
      if (outward > 0) {
        _farX = _pointerX;
      } else if (-outward > _slack) {
        _stoppedSide = _side;
        _nearX = _pointerX;
        _setSide(0);
      }
    } else if (_stoppedSide != 0) {
      final outward = _stoppedSide * (_pointerX - _nearX);
      if (outward < 0) {
        _nearX = _pointerX;
      } else if (outward > _slack) {
        _setSide(_stoppedSide);
        _stoppedSide = 0;
      }
    }
  }

  void _stretch() {
    setState(() {
      if (_side > 0) {
        _hi = math.min(_hi * _growth, _ceiling);
      } else {
        _lo = math.max(_lo / _growth, _floor);
      }
    });
    _emit(_factorAt(_t));
  }

  void _handleEnd(double logFactor) {
    _setSide(0);
    _held = false;
    _stoppedSide = 0;
    final factor = _last ?? math.exp(logFactor);
    _last = null;
    setState(() {
      _lo = widget.initialMin;
      _hi = widget.initialMax;
    });
    widget.onChangeEnd(factor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final factor = widget.factor.clamp(_floor, _ceiling).toDouble();
    final lo = math.log(math.min(_lo, factor));
    final hi = math.log(math.max(_hi, factor));
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          Text(widget.leadingLabel, style: theme.textTheme.bodySmall),
          Expanded(
            child: MergeSemantics(
              child: Semantics(
                label: widget.semanticsLabel,
                child: SizedBox(
                  height: 56,
                  // The raw pointer keeps arriving here after the finger has
                  // left the slider, which the stretch rule needs.
                  child: Listener(
                    onPointerDown: _handlePointer,
                    onPointerMove: _handlePointer,
                    child: SliderTheme(
                      // With slideThumb only a touch inside the overlay
                      // circle grabs the thumb, so the circle is the touch
                      // target: 56 px, the app's minimum, not the 48 default.
                      data: SliderTheme.of(context).copyWith(
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28),
                      ),
                      child: Slider(
                        value: math.log(factor).clamp(lo, hi).toDouble(),
                        min: lo,
                        max: hi,
                        activeColor: theme.colorScheme.primary,
                        // A touch on the track must not jump the value (and
                        // then save it on release): only the thumb moves the
                        // factor.
                        allowedInteraction: SliderInteraction.slideThumb,
                        semanticFormatterCallback: (v) =>
                            '×${math.exp(v).toStringAsFixed(2)}',
                        onChangeStart: _handleStart,
                        onChanged: _handleChanged,
                        onChangeEnd: _handleEnd,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Text(widget.trailingLabel, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
