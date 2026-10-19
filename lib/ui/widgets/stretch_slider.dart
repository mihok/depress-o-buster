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
/// person holds. Moving back towards the middle stops the stretching; the
/// widened range stays until release, when it returns to
/// [initialMin]..[initialMax] around whatever factor the parent then holds
/// (typically ×1 again). The factor never leaves 0.01..100.
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
  static const double _floor = 0.01;
  static const double _ceiling = 100;
  static const double _edge = 0.06;
  static const double _growth = 1.15;
  static const Duration _tick = Duration(milliseconds: 120);

  late double _lo = widget.initialMin;
  late double _hi = widget.initialMax;

  /// Where the thumb sits along the track, 0 at the left end, 1 at the right.
  double _t = 0.5;

  /// -1 while the minimum is stretching, 1 the maximum, 0 neither.
  int _side = 0;

  /// The last factor handed to [StretchSlider.onChanged] in this drag.
  double? _last;
  Timer? _timer;

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

  void _handleStart(double _) {
    _lo = math.min(widget.initialMin, widget.factor);
    _hi = math.max(widget.initialMax, widget.factor);
  }

  void _handleChanged(double logFactor) {
    final span = math.log(_hi) - math.log(_lo);
    _t = ((logFactor - math.log(_lo)) / span).clamp(0.0, 1.0).toDouble();
    final side = _t >= 1 - _edge ? 1 : (_t <= _edge ? -1 : 0);
    if (side != _side) {
      _timer?.cancel();
      _side = side;
      if (side != 0) _timer = Timer.periodic(_tick, (_) => _stretch());
    }
    _emit(_factorAt(_t));
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
    _timer?.cancel();
    _timer = null;
    _side = 0;
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
                  child: Slider(
                    value: math.log(factor).clamp(lo, hi).toDouble(),
                    min: lo,
                    max: hi,
                    activeColor: theme.colorScheme.primary,
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
          Text(widget.trailingLabel, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
