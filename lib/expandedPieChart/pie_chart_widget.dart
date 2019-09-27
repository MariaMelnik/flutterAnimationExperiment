import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_painter.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';

const double _defaultInitValue = 1.0;
const Duration _changeRotationAnimationDuration = const Duration(milliseconds: 300);
const Curve _animationCurve = Curves.easeOut;

class PieChart extends ImplicitlyAnimatedWidget {
  final List<PieChartSector> sectors;
  final double rotateAngle;

  PieChart({
    @required this.sectors,
    @required this.rotateAngle,
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
                sectors: widget.sectors
            ),
          ),
        ),
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _turnAnimation = visitor(_turnAnimation, widget.rotateAngle, (val) => Tween(begin: val));
    assert(_turnAnimation != null);
  }
}




