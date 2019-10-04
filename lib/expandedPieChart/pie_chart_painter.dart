import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';
import 'dart:math';

class PieChartPainter extends CustomPainter{
  final List<PieChartSector> sectors;

  // Can be null. All sectors will be selected.
  final PieChartSector selectedSector;

  final PieChartSector previousSelectedSector;

  // How much we should add to 0.5 for opacity of the [selectedSector].
  // How much we should reduce 1 for opacity of the [previousSelectedSector].
  final double opacityDelta;

  // How many of the pie should be visible.
  // By default 2*pi what means all pie is visible.
  final double maxShownAngle;

  final Paint _painter;

  PieChartPainter({
    @required this.sectors,
    this.selectedSector,
    this.previousSelectedSector,
    this.maxShownAngle = 2 * pi,
    this.opacityDelta,
  }):
        _painter = Paint()
          ..style = PaintingStyle.stroke,
        assert (sectors!=null);


  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    canvas.save();
    canvas.translate(radius, radius);

    sectors.forEach((PieChartSector sector) => _paintSector(canvas, sector, radius));
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }


  void _paintSector(Canvas canvas, PieChartSector sector, double radius){
    double endAngleChecked = sector.startAngle > sector.endAngle
        ? sector.startAngle
        : sector.endAngle;

    if (sector.startAngle > maxShownAngle) return;
    if (endAngleChecked > maxShownAngle) endAngleChecked = maxShownAngle;

    double sectorWidthChecked = sector.sectorWidth > radius
        ? radius
        : sector.sectorWidth;

    //how much we should paint
    double sweepAngle = endAngleChecked - sector.startAngle;

    Rect outerRect = Rect.fromPoints(
        Offset(-radius + sectorWidthChecked/2, -radius + sectorWidthChecked/2),
        Offset(radius - sectorWidthChecked/2, radius - sectorWidthChecked/2)
    );


    // [selectedSector] == [previousSelectedSector] at the very beginning. When no sector was selected.
    if (selectedSector != null && selectedSector != previousSelectedSector) {
      if (sector == selectedSector) _painter.color = sector.color.withOpacity(0.5 + opacityDelta);
      else if (sector == previousSelectedSector) _painter.color = sector.color.withOpacity(1 - opacityDelta);
      else _painter.color = sector.color.withOpacity(0.5);
    } else {
      _painter.color = sector.color.withOpacity(1.0);
    }

    _painter.strokeWidth = sectorWidthChecked;

    canvas.drawArc(
        outerRect,
        sector.startAngle,
        sweepAngle,
        false,
        _painter
    );
  }
}