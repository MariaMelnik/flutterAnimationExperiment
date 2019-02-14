import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';

//fixme: come up with better class name
class RotatePieDataSet {
  final double value;
  final Color color;
  final Widget child;

  RotatePieDataSet({
    @required this.value,
    @required this.color,
    @required this.child
  }) : assert (value != null),
       assert(color != null),
       assert(child != null);
}

//fixme: come up with better class name
class RotatePieBuildingInfo {
  final PieChartSector sector;
  final Color color;
  final Widget child;

  RotatePieBuildingInfo({
    @required this.sector,
    @required this.color,
    @required this.child
  }): assert (sector != null),
      assert(color != null),
      assert(child != null);
}