import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/gauge/arrow_painter.dart';
import 'package:flutter_gauge_test/gauge/baseline_painter.dart';
import 'package:flutter_gauge_test/gauge/gauge_decoration.dart';
import 'package:flutter_gauge_test/gauge/limit_arrow_painter.dart';
import 'package:flutter_gauge_test/gauge/range_painter.dart';
import 'package:flutter_gauge_test/gauge/ticks_painter.dart';

const double _defaultInitValue = 1.0;
const Duration _changeRotationAnimationDuration = const Duration(milliseconds: 300);
const Curve _animationCurve = Curves.easeOut;

class GaugeWidget extends ImplicitlyAnimatedWidget {
  final GaugeDecoration gaugeDecoration;
  final num minVal;
  final num maxVal;
  final num curVal;
  final num baselineVal;
  final num initVal;
  final num limitVal;
  final GaugeType gaugeType;

  const GaugeWidget({
    Key key,
    @required this.minVal,
    @required this.maxVal,
    @required this.curVal,
    this.initVal,
    this.baselineVal,
    this.limitVal,
    this.gaugeDecoration,
    this.gaugeType = GaugeType.defaultGauge
  }) : super(
      key: key,
      duration: _changeRotationAnimationDuration,
      curve: _animationCurve);

  @override
  GaugeWidgetState createState() => GaugeWidgetState();
}


class GaugeWidgetState extends AnimatedWidgetBaseState<GaugeWidget> {
  Tween _arrowAnimation;

  @override
  void forEachTween(visitor) {
    _arrowAnimation = visitor(_arrowAnimation, widget.curVal ?? _defaultInitValue, (val) => Tween(begin: val));
    assert(_arrowAnimation != null);
  }

  TickPainter _buildTickPainter(){
    return TickPainter(
        tickCount: widget.gaugeDecoration.ticksCount,
        ticksPerSection: widget.gaugeDecoration.ticksPerSection,
        minVal: widget.minVal,
        maxVal: widget.maxVal,
        tickColor: widget.gaugeDecoration.tickColor,
        tickWidth: widget.gaugeDecoration.tickWidth,
        textStyle: widget.gaugeDecoration.textStyle
    );
  }


  Widget _buildRanges(List<GaugeRangeDecoration> ranges){
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: RangePainter(
            max: widget.maxVal,
            min: widget.minVal,
            ranges: ranges,
            rangeWidth: widget.gaugeDecoration.rangeWidth
        ),
      ),
    );
  }

  // return different colorful sector depends on gauge type
  Widget _buildRangesByType(GaugeType type) {
    if(widget.gaugeDecoration.rangesDecoration == null || widget.gaugeDecoration.rangesDecoration.isEmpty) return Container(width: 0.0, height: 0.0,);

    switch(type) {
      case GaugeType.defaultGauge:
        List<GaugeRangeDecoration> ranges = widget.gaugeDecoration.rangesDecoration;
        return RepaintBoundary(
          child: _buildRanges(ranges),
        );
        break;
      case GaugeType.valueDriverGauge:
       return _buildRanges(_getValueDrivenRanges(_arrowAnimation.evaluate(animation) as double));
    }
  }

  // building something like this https://dribbble.com/shots/2467087-Daily-workout-statistics-Card
  List<GaugeRangeDecoration> _getValueDrivenRanges(double curVal){
    List<GaugeRangeDecoration> newRanges;

    // what color we should use
    // define according to appropriate sector for _curVal
    GaugeRangeDecoration curDecoration = widget.gaugeDecoration.rangesDecoration
        .firstWhere((GaugeRangeDecoration dec) => dec.minVal < curVal && dec.maxVal >= curVal,
        orElse: () => null);

    if (curDecoration != null) {
      Color curColor = curDecoration.color;

      // need to normalize cur if it is out of the boundaries
      double normalizedCur;
      if (curVal < widget.minVal) normalizedCur = widget.minVal;
      else if (curVal > widget.maxVal) normalizedCur = widget.maxVal;
      else normalizedCur = curVal;

      GaugeRangeDecoration beforeCurVal = GaugeRangeDecoration(minVal: widget.minVal, maxVal: normalizedCur, color: curColor);
      GaugeRangeDecoration afterCurVal = GaugeRangeDecoration(minVal: normalizedCur, maxVal: widget.maxVal, color: Colors.black38);

      newRanges = [beforeCurVal, afterCurVal];
    } else {
      GaugeRangeDecoration newRange = GaugeRangeDecoration(minVal: widget.minVal, maxVal: widget.maxVal, color: Colors.lightGreen);
      newRanges = [newRange];
    }

    return newRanges;
  }

  Widget _buildTicks(){
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: CustomPaint(
          painter: _buildTickPainter(),
        ),
      ),
    );
  }

  double _getRotationPercent(double min, double max, num value){
    return (value-min)/(max-min);
  }

  Widget _buildArrow(){
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: CustomPaint(
        painter: ArrowPainter(
            rotationPercent: _getRotationPercent(widget.minVal, widget.maxVal, _arrowAnimation.evaluate(animation) as double),
            arrowColor: widget.gaugeDecoration.arrowColor,
            arrowPaintingStyle: widget.gaugeDecoration.arrowPaintingStyle,
            arrowEndShift: widget.gaugeDecoration.arrowEndShift,
            arrowStartWidth: widget.gaugeDecoration.arrowStartWidth
        ),
      ),
    );
  }

  Widget _buildBaseline(){
    if (widget.baselineVal == null) return Container(height: 0.0, width: 0.0,);
    else {
      return RepaintBoundary(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: CustomPaint(
            key: Key("baselinePainter"),
            painter: BaselinePainter(
                min: widget.minVal,
                max: widget.maxVal,
                baselineVal: widget.baselineVal,
                color: widget.gaugeDecoration.baselineColor,
                lineWidth: widget.gaugeDecoration.baselineWidth,
                paintingStyle: widget.gaugeDecoration.baselinePaintingStyle
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLimitArrow(){
    if (widget.limitVal == null) return Container(height: 0.0, width: 0.0,);
    else {
      return RepaintBoundary(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: CustomPaint(
            key: Key("limitPainter"),
            painter: LimitArrowPainter(
                minVal: widget.minVal,
                maxVal: widget.maxVal,
                limitVal: widget.limitVal,
                color: widget.gaugeDecoration.limitArrowColor,
                paintingStyle: widget.gaugeDecoration.limitArrowPaintingStyle,
                arrowHeight: widget.gaugeDecoration.limitArrowHeight,
                arrowWidth: widget.gaugeDecoration.limitArrowWidth,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
//        color: widget.gaugeDecoration.backgroundColor,
        borderRadius: BorderRadius.circular(10.0)
      ),
      padding: const EdgeInsets.all(10.0),
      child: AspectRatio(
        aspectRatio: 2.0,
        child: Stack(
          children: [
            _buildRangesByType(widget.gaugeType),
            _buildTicks(),
            _buildBaseline(),
            _buildArrow(),
            _buildLimitArrow(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }
}

enum GaugeType {
  // default gauge with persistent ranges (if exists)
  defaultGauge,

  // gauge with ranges depends on value (before curVal and after curVal)
  valueDriverGauge
}