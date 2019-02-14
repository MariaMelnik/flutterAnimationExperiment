import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';

class PieChartPainter extends CustomPainter{
  final Paint painter;
  final List<PieChartSector> sectors;

  PieChartPainter({
    @required this.sectors
  }):
        painter = Paint(),
        assert (sectors!=null)
  {
    painter.style = PaintingStyle.stroke;
  }

  
  void _paintSector(Canvas canvas, PieChartSector sector, double radius){
    double endAngleChecked = sector.startAngle > sector.endAngle
        ? sector.startAngle
        : sector.endAngle;

    double sectorWidthChecked = sector.sectorWidth > radius
        ? radius
        : sector.sectorWidth;

    //how much we should paint
    double sweepAngle = endAngleChecked - sector.startAngle;

    Rect outerRect = Rect.fromPoints(
        Offset(-radius + sectorWidthChecked/2, -radius + sectorWidthChecked/2),
        Offset(radius - sectorWidthChecked/2, radius - sectorWidthChecked/2)
    );

    painter.color = sector.color;
    painter.strokeWidth = sectorWidthChecked;

    canvas.drawArc(
        outerRect,
        sector.startAngle,
        sweepAngle,
        false,
        painter
    );
  }

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
}