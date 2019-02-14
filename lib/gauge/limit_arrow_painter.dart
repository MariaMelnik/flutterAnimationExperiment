import 'package:flutter/material.dart';
import 'dart:math';

class LimitArrowPainter extends CustomPainter{
  final num limitVal;
  final num maxVal;
  final num minVal;
  final Paint painter;
  final Color color;
  final PaintingStyle paintingStyle;
  final double arrowHeight;
  final double arrowWidth;

  LimitArrowPainter({
    @required this.limitVal,
    @required this.maxVal,
    @required this.minVal,
    @required this.color,
    @required this.paintingStyle,
    @required this.arrowHeight,
    @required this.arrowWidth
  }) : painter = Paint(),
      assert (limitVal != null),
      assert (maxVal != null),
      assert (minVal != null),
      assert (maxVal >= minVal),
      assert (color != null),
      assert (paintingStyle != null),
      assert (arrowHeight != null),
      assert (arrowWidth != null)
  {
    painter.style = paintingStyle;
    painter.color = color;
  }


  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    double limitValChecked = limitVal;
    if (limitVal > maxVal) limitValChecked = maxVal;
    if (limitVal < minVal) limitValChecked = minVal;

    double percent = (limitValChecked - minVal)/(maxVal - minVal);
    double angle = -pi/2 + pi * percent;

    canvas.translate(radius, radius);

    canvas.save();

    canvas.rotate(angle);

    Path path = Path();
    path.moveTo(0.0, -radius);
    path.lineTo(-arrowWidth/2, -radius - arrowHeight);
    path.lineTo(arrowWidth/2, -radius - arrowHeight);
    path.close();

    canvas.drawPath(path, painter);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}