import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_gauge_test/gauge/gauge_decoration.dart';

class RangePainter extends CustomPainter{
  final List<GaugeRangeDecoration> ranges;
  final num min;
  final num max;
  final double rangeWidth;

  RangePainter({
    @required this.ranges,
    @required this.max,
    @required this.min,
    @required this.rangeWidth
  }) : assert (max != null),
        assert (min != null),
        assert (max >= min),
        assert (rangeWidth != null);
//        assert (ranges.length == 0 || ranges.every((range) => range.minVal >= min)),
//        assert (ranges.length == 0 || ranges.every((range) => range.maxVal <= max));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width/2, size.height);

    double radius = size.height;
    Rect rect = Rect.fromPoints(
        Offset(-radius + rangeWidth/2, -radius + rangeWidth/2),
        Offset(radius - rangeWidth/2, radius - rangeWidth/2)
    );

    ranges.forEach((GaugeRangeDecoration decoration) => _paintRange(canvas, decoration, rect, radius));
  }

  void _paintRange(Canvas canvas, GaugeRangeDecoration decoration, Rect outerRect, double radius){
    num rangeMinChecked = decoration.minVal < min
        ? min
        : decoration.minVal;

    rangeMinChecked = math.min(rangeMinChecked, max);


    num rangeMaxChecked = decoration.maxVal > max
        ? max
        : decoration.maxVal >= rangeMinChecked
          ? decoration.maxVal
          : rangeMinChecked;

    rangeMaxChecked = math.max(rangeMaxChecked, min);


    double rangeWidthChecked = rangeWidth > radius
        ? radius
        : rangeWidth;

    Paint paint = Paint()
      ..color = decoration.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = rangeWidthChecked;

    double arcAngleFrom = (rangeMinChecked-min) / (max-min)* math.pi + -math.pi;
    double arcAngle = (rangeMaxChecked-rangeMinChecked) / (max-min) * math.pi;

    canvas.drawArc(
        outerRect,
        arcAngleFrom,
        arcAngle,
        false,
        paint
    );
  }

  @override
  bool shouldRepaint(RangePainter oldDelegate) {
    bool boundariesAreChanged = oldDelegate.min != min || oldDelegate.max != max;
    bool rangesChanged = oldDelegate.ranges != ranges;
    bool widthChanged = oldDelegate.rangeWidth != rangeWidth;

    return boundariesAreChanged || rangesChanged || widthChanged;
  }
}