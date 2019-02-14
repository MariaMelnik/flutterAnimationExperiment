import 'package:flutter/material.dart';

class PieChartSector {
  final double startAngle;
  final double endAngle;
  final Color color;
  final double sectorWidth;

  const PieChartSector({
    @required this.startAngle,
    @required this.endAngle,
    @required this.color,
    @required this.sectorWidth
  }) : assert(startAngle != null),
        assert(endAngle != null),
//       assert(startAngle <= endAngle),
        assert(color != null),
        assert(sectorWidth != null && sectorWidth >= 0.0);
}