import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_painter.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';
import 'dart:math';

const Duration _changeRotationAnimationDuration = const Duration(milliseconds: 300);
const Curve _animationCurve = Curves.easeOut;
const double _opacityThreshold = 0.5; // default opacity for unselected sectors

class RotatedPieChart extends ImplicitlyAnimatedWidget {
  final List<PieChartSector> sectors;
  final double rotateAngle;

  // How many of the pie should be visible.
  // By default 2*pi what means all pie is visible.
  final double maxShowAngle;

  /// Opacity delta of the selected sector.
  /// Also used for changing opacity for previous selected sector.
  final double selectedOpacityDelta;

  final PieChartSector selectedSector;

  final PieChartSector previousSelectedSector;

  RotatedPieChart({
    @required this.sectors,
    @required this.rotateAngle,
    @required this.selectedSector,
    @required this.previousSelectedSector,
    this.selectedOpacityDelta,
    this.maxShowAngle = 2 * pi,
    Key key
  }) : assert(sectors != null),
        assert(rotateAngle != null),
        super(
          key: key,
          duration: _changeRotationAnimationDuration,
          curve: _animationCurve
        );


  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends AnimatedWidgetBaseState<RotatedPieChart> {
  Tween _turnAnimation;
  Tween _fillAnimation;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Transform.rotate(
          angle: _turnAnimation.evaluate(animation) as double,
          child: _buildPieWithOpacityAnimation()
        ),
      ),
    );
  }

  Widget _buildPieWithOpacityAnimation(){
    return CustomPaint(
      painter: PieChartPainter(
        sectors: widget.sectors,
        selectedSector: widget.selectedSector,
        previousSelectedSector: widget.previousSelectedSector,
        maxShownAngle: _fillAnimation.evaluate(animation) as double,
        opacityDelta: widget.selectedOpacityDelta
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _turnAnimation = visitor(_turnAnimation, widget.rotateAngle, (val) => Tween(begin: val));
    _fillAnimation = visitor(_fillAnimation, widget.maxShowAngle, (val) => Tween(begin: val));
    assert(_turnAnimation != null);
    assert(_fillAnimation != null);
  }
}




