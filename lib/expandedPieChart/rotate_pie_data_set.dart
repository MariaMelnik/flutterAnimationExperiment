import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';

class RotatePieBuildingInfo {
  final PieChartSector sector;

  /// Color for tab view and tab indicator correlated with [sector].
  ///
  /// If null - [sector.color] will be used.
  /// It means tab view and tab indicator for this [sector] will be same color as [sector] itself.
  final Color color;

  /// Widget in tab view correlated with [sector].
  final Widget child;

  RotatePieBuildingInfo({
    @required this.sector,
    @required this.child,
    Color color
  }): assert (sector != null),
      assert(child != null),
      color = sector.color;
}