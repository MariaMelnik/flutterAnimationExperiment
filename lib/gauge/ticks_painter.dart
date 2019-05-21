import 'package:flutter/material.dart';
import 'dart:math';

const int _longTickRatio = 26; //width/tick_length
const int _fontSizeRatio = 27; //width/font/size

class TickPainter extends CustomPainter {
  final double maxVal;
  final double minVal;
  final int tickCount;
  final int ticksPerSection;
  final Color tickColor;
  final double tickWidth;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;


  TickPainter({
    @required this.minVal,
    @required this.maxVal,
    @required this.textStyle,
    @required this.tickCount,
    @required this.ticksPerSection,
    @required this.tickColor,
    @required this.tickWidth
  }) : tickPaint = Paint(),
        textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
        assert(minVal!=null),
        assert(maxVal!=null),
        assert(maxVal>=minVal),
        assert(textStyle!=null),
        assert(tickCount!=null),
        assert(ticksPerSection!=null),
        assert(tickColor!=null),
        assert(tickWidth!=null)
  {
    tickPaint.color = tickColor;
    tickPaint.strokeWidth = tickWidth;
  }

  //return appropriate text style
  //if [this.textStyle] is not set, calculate one with default color and calculated font size
  //if [this.textStyle] doesn't have fontSize property, returns copied textStyle with calculated forn size
  //in other cases return [this.textStyle]
  TextStyle _getStyle(double width){
    TextStyle result;
    double calculatedFontSize = width/_fontSizeRatio;
    if (calculatedFontSize < 8.0) calculatedFontSize = 8.0;

    if (textStyle.fontSize == null){
      result =  textStyle.copyWith(
          fontSize: calculatedFontSize
      );
    } else {
      result = textStyle;
    }

    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    //we can't store this as instance variables because we need calculate it according to given [size]
    //todo: может надо сохранять size и в shouldRepaint проверять его изменение
    final double longTick = size.width/_longTickRatio;
    final double shortTick = longTick / 2.5;
    final double radius = size.width / 2;
    final double interval = (maxVal - minVal)/(tickCount-1);
    final TextStyle style = _getStyle(size.width);
    final double textOffset = style.fontSize * 2;

    canvas.translate(size.width / 2, size.height);

    canvas.save();

    canvas.rotate(pi/2 + pi); //270

    for (var i = 0; i < tickCount; ++i) {
      final tickLength = i % ticksPerSection == 0 ? longTick : shortTick;

      canvas.drawLine(
        Offset(0.0, -radius),
        Offset(0.0, -radius + tickLength),
        tickPaint,
      );

      if (i % ticksPerSection == 0) {
        // Paint text.
        canvas.save();
        canvas.translate(0.0, -(radius) + textOffset);

        final double val = minVal + interval*i;
        String valStr = maxVal <= 1
            ? val.toStringAsFixed(1)
            : val.toStringAsFixed(0);


        textPainter.text = TextSpan(
          text: valStr,
          style: style,
        );

        // Layout the text
        textPainter.layout();

        textPainter.paint(
          canvas,
          Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );
        canvas.restore();
      }
      canvas.rotate(pi / (tickCount-1));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}