import 'package:flutter/material.dart';

//arrow defaults
const Color _arrowColor = Colors.black;
const PaintingStyle _arrowPaintingStyle = PaintingStyle.fill;
const double _arrowStartWidth = 8.0;
const double _arrowEndShift = 10.0;

//ticks defaults
const int _ticksCount = 11;
const int _tickPerSection = 2;
const Color _textColor = Colors.grey;
const Color _tickColor = Colors.black;
const double _tickWidth = 1.8;

//value text defaults
const TextStyle _valueTextStyle = TextStyle(color: _textColor);

//ranges defaults
const double _rangeWidth = 20.0;

//baseline defaults
const Color _baselineColor = Colors.blueGrey;
const double _baselineWidth = 2.0;
const PaintingStyle _baselinePaintingStyle = PaintingStyle.stroke;

//limit arrow
const double _limitArrowWidth = 6.0;
const double _limitArrowHeight = 8.0;
const Color _limitArrowColor = Colors.red;
const PaintingStyle _limitArrowPaintingStyle = PaintingStyle.fill;

//background
const Color _backgroundColor = Colors.white;

class GaugeDecoration {
  //background
  final Color backgroundColor;

  //arrow decoration
  final Color arrowColor;
  final PaintingStyle arrowPaintingStyle;
  //width of the bottom of arrow. Circle diameter as well.
  final double arrowStartWidth;
  //how many place there is between arrow end (thicker place) and the outer gauge boundary
  final double arrowEndShift;

  //ticks decoration
  final Color tickColor;
  final double tickWidth;
  final int ticksCount;
  final int ticksPerSection;

  //style for number text spans under ticks
  final TextStyle textStyle;

  //ranges decoration
  final List<GaugeRangeDecoration> rangesDecoration;
  final double rangeWidth;

  //baseline decoration
  final double baselineWidth;
  final Color baselineColor;
  final PaintingStyle baselinePaintingStyle;

  //limit arrow decoration
  final double limitArrowWidth;
  final double limitArrowHeight;
  final Color limitArrowColor;
  final PaintingStyle limitArrowPaintingStyle;

  const GaugeDecoration({
    Color arrowColor,
    PaintingStyle arrowPaintingStyle,
    double arrowEndShift,
    double arrowStartWidth,
    Color tickColor,
    double tickWidth,
    TextStyle textStyle,
    double rangeWidth,
    int ticksCount,
    int ticksPerSection,
    Color baselineColor,
    double baselineWidth,
    PaintingStyle baselinePaintingStyle,
    Color backgroundColor,
    double limitArrowHeight,
    double limitArrowWidth,
    Color limitArrowColor,
    PaintingStyle limitArrowPaintingStyle,
    this.rangesDecoration,
  })  : this.arrowColor = arrowColor ?? _arrowColor,
        this.arrowPaintingStyle = arrowPaintingStyle ?? _arrowPaintingStyle,
        this.arrowEndShift = arrowEndShift ?? _arrowEndShift,
        this.arrowStartWidth = arrowStartWidth ?? _arrowStartWidth,
        this.tickColor = tickColor ?? _tickColor,
        this.tickWidth = tickWidth ?? _tickWidth,
        this.textStyle = textStyle ?? _valueTextStyle,
        this.rangeWidth = rangeWidth ?? _rangeWidth,
        this.ticksCount = ticksCount ?? _ticksCount,
        this.ticksPerSection = ticksPerSection ?? _tickPerSection,
        this.baselineColor = baselineColor ?? _baselineColor,
        this.baselineWidth = baselineWidth ?? _baselineWidth,
        this.baselinePaintingStyle =
            baselinePaintingStyle ?? _baselinePaintingStyle,
        this.backgroundColor = backgroundColor ?? _backgroundColor,
        this.limitArrowHeight = limitArrowHeight ?? _limitArrowHeight,
        this.limitArrowWidth = limitArrowWidth ?? _limitArrowWidth,
        this.limitArrowColor = limitArrowColor ?? _limitArrowColor,
        this.limitArrowPaintingStyle =
            limitArrowPaintingStyle ?? _limitArrowPaintingStyle;

  /// Creates a copy of this decorations but with the given fields replaced with the new values.
  GaugeDecoration copyWith(
      {Color arrowColor,
      PaintingStyle arrowPaintingStyle,
      double arrowEndShift,
      double arrowStartWidth,
      Color tickColor,
      double tickWidth,
      TextStyle textStyle,
      double rangeWidth,
      int ticksCount,
      int ticksPerSection,
      Color baselineColor,
      double baselineWidth,
      PaintingStyle baselinePaintingStyle,
      Color backgroundColor,
      double limitArrowHeight,
      double limitArrowWidth,
      Color limitArrowColor,
      PaintingStyle limitArrowPaintingStyle,
      List<GaugeRangeDecoration> rangesDecoration}) {
    return GaugeDecoration(
      arrowColor: arrowColor ?? this.arrowColor,
      arrowPaintingStyle: arrowPaintingStyle ?? this.arrowPaintingStyle,
      arrowEndShift: arrowEndShift ?? this.arrowEndShift,
      arrowStartWidth: arrowStartWidth ?? this.arrowStartWidth,
      tickColor: tickColor ?? this.tickColor,
      tickWidth: tickWidth ?? this.tickWidth,
      textStyle: textStyle ?? this.textStyle,
      rangeWidth: rangeWidth ?? this.rangeWidth,
      ticksCount: ticksCount ?? this.ticksCount,
      ticksPerSection: ticksPerSection ?? this.ticksPerSection,
      baselineColor: baselineColor ?? this.baselineColor,
      baselineWidth: baselineWidth ?? this.baselineWidth,
      baselinePaintingStyle: baselinePaintingStyle ?? this.baselinePaintingStyle,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      limitArrowHeight: limitArrowHeight ?? this.limitArrowHeight,
      limitArrowWidth: limitArrowWidth ?? this.limitArrowWidth,
      limitArrowColor: limitArrowColor ?? this.limitArrowColor,
      limitArrowPaintingStyle: limitArrowPaintingStyle ?? this.limitArrowPaintingStyle,
      rangesDecoration: rangesDecoration ?? this.rangesDecoration
    );
  }
}

class GaugeRangeDecoration {
  final num minVal;
  final num maxVal;
  final Color color;

  const GaugeRangeDecoration({
    @required this.minVal,
    @required this.maxVal,
    @required this.color
  }) : assert (minVal <= maxVal);
}
