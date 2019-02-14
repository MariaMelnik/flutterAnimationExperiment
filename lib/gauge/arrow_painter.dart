import 'package:flutter/material.dart';
import 'dart:math';

class ArrowPainter extends CustomPainter{
  final Paint arrowPaint;
  final double rotationPercent;
  final Color arrowColor;
  final PaintingStyle arrowPaintingStyle;

  //width of the bottom of arrow. Circle diameter as well.
  final double arrowStartWidth;

  //how many place there is between arrow end (thicker place) and the outer gauge boundary
  final double arrowEndShift;


  ArrowPainter({
    @required this.rotationPercent,
    @required this.arrowColor,
    @required this.arrowPaintingStyle,
    @required this.arrowStartWidth,
    @required this.arrowEndShift
  }): arrowPaint = Paint(),
        assert(arrowColor!=null),
        assert(arrowPaintingStyle!=null),
        assert(rotationPercent!=null),
        assert(arrowStartWidth!=null && arrowStartWidth > 0),
        assert(arrowEndShift!=null && arrowEndShift >= 0)
  {
    arrowPaint.color = arrowColor;
    arrowPaint.style = arrowPaintingStyle;
  }


  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    double rotation = rotationPercent;
    if (rotationPercent > 1) rotation = 1;
    if (rotationPercent < 0) rotation = 0;

    canvas.translate(size.width/2, size.height);
    canvas.rotate(-pi/2 + pi * rotation);

    Path path = Path();
    //todo: поменять на относительные величины с коэффициентом вместо абсолютных(4)
    path.moveTo(-arrowStartWidth/2, 0);
    path.lineTo(0, -size.height + arrowEndShift);
    path.lineTo(arrowStartWidth/2, 0);
    path.close();

    canvas.drawPath(path, arrowPaint);
    canvas.drawCircle(Offset(0.0, 0.0), arrowStartWidth/2, arrowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}