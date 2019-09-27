import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_painter.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';
import 'dart:math';

const Duration _changeRotationAnimationDuration = const Duration(milliseconds: 300);
const Curve _animationCurve = Curves.easeOut;
const double _opacityThreshold = 0.5; // default opacity for unselected sectors

class PieChart extends ImplicitlyAnimatedWidget {
  final List<PieChartSector> sectors;
  final double rotateAngle;

  // Can be null if no sector selected.
  final PieChartSector selectedSector;

  // How many of the pie should be visible.
  // By default 2*pi what means all pie is visible.
  final double maxShowAngle;

  PieChart({
    @required this.sectors,
    @required this.rotateAngle,
    this.selectedSector,
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

class _PieChartState extends AnimatedWidgetBaseState<PieChart> {
  Tween _turnAnimation;
  Tween _fillAnimation;
  Tween _selectedOpacity;

  PieChartSector _previousSelectedSector;

  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedSector != widget.selectedSector) {
      _selectedOpacity = Tween(begin: 0.0, end: _opacityThreshold);
      _previousSelectedSector = oldWidget.selectedSector;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Transform.rotate(
          angle: _turnAnimation.evaluate(animation) as double,
          child: CustomPaint(
            painter: PieChartPainter(
              sectors: widget.sectors,
              selectedSector: widget.selectedSector,
              previousSelectedSector: _previousSelectedSector,
              maxShownAngle: _fillAnimation.evaluate(animation) as double,
              opacityDelta: _selectedOpacity.evaluate(animation) as double
            ),
          ),
        ),
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _turnAnimation = visitor(_turnAnimation, widget.rotateAngle, (val) => Tween(begin: val));
    _fillAnimation = visitor(_fillAnimation, widget.maxShowAngle, (val) => Tween(begin: val));
    _selectedOpacity = visitor(_selectedOpacity, _opacityThreshold, (val) => Tween(begin: val));
    assert(_turnAnimation != null);
    assert(_fillAnimation != null);
    assert(_selectedOpacity != null);
  }
}




