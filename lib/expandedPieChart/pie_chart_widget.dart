import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_painter.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';

class PieChart extends StatelessWidget {
  final List<PieChartSector> sectors;

  PieChart({
    @required this.sectors,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: CustomPaint(
          painter: PieChartPainter(
            sectors: sectors
          ),
        ),
      ),
    );
  }
}




