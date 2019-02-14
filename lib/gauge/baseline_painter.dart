import 'package:flutter/material.dart';
import 'dart:math';

class BaselinePainter extends CustomPainter{
  final num baselineVal;
  final num max;
  final num min;
  final Paint painter;
  final Color color;
  final PaintingStyle paintingStyle;
  final double lineWidth;

  BaselinePainter({
    @required this.baselineVal,
    @required this.max,
    @required this.min,
    @required this.color,
    @required this.paintingStyle,
    @required this.lineWidth
  }) : painter = Paint(),
        assert (max != null && min != null && baselineVal != null),
        assert (max >= min),
        assert (min <= baselineVal && max >= baselineVal),
        assert (color != null),
        assert (lineWidth != null),
        assert (paintingStyle != null)
  {
    painter.color = color;
    painter.style = paintingStyle;
    painter.strokeWidth = lineWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double percent = (baselineVal - min) / (max-min);
    double angle = -pi/2 + pi * percent;
    double radius = size.width/2;

    canvas.translate(radius, radius);

    canvas.save();
    canvas.rotate(angle);

    canvas.drawLine(Offset(0.0, 0.0), Offset(0.0, -radius), painter);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }

}