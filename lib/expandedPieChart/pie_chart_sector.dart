import 'package:flutter/material.dart';

class PieChartSector {
  // Angle in radians. Between 0.0 and 2*pi.
  final double startAngle;

  // Angle in radians. Between 0.0 and 2*pi.
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