import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie_data_set.dart';

class RotatePieMockData {
  static const double total = 100;


  static List<RotatePieDataSet> dataSets = [
    RotatePieDataSet(color: Colors.green, value: 30.0, child: Container()),
    RotatePieDataSet(color: Colors.purple, value: 10.0, child: Container()),
    RotatePieDataSet(color: Colors.orange, value: 40.0, child: Container()),
    RotatePieDataSet(color: Colors.blueGrey, value: 15.0, child: Container()),
    RotatePieDataSet(color: Colors.yellow, value: 5.0, child: Container()),
//
//    RotatePieDataSet(color: Colors.purple, value: 25.0, child: Container()),
//    RotatePieDataSet(color: Colors.orange, value: 25.0, child: Container()),
//    RotatePieDataSet(color: Colors.blueGrey, value: 25.0, child: Container()),
//    RotatePieDataSet(color: Colors.yellow, value: 25.0, child: Container()),
  ];

  static List<RotatePieBuildingInfo> getBuildingInfo(List<RotatePieDataSet> dataSets, double total) {
    double lastEndAngle = 0;
    double maxAngle = 2* pi;

    return dataSets.map((RotatePieDataSet dataSet) {
      double lastEndTemp = (dataSet.value / total) * maxAngle;
      double lastEndCalculated = lastEndTemp + lastEndAngle;

      PieChartSector sector = PieChartSector(
          startAngle: lastEndAngle,
          endAngle: lastEndCalculated,
          color: dataSet.color,
          sectorWidth: 150.0
      );//todo: remove hardcoded part
//      print("value is ${dataSet.value}, lastEndTemp is: ${lastEndTemp}");
//      print("color is: ${dataSet.color}, startAngle: $lastEndAngle, endAngle: ${lastEndCalculated}");
      lastEndAngle = lastEndCalculated;
      return RotatePieBuildingInfo(
          sector: sector,
          color: dataSet.color,
          child: dataSet.child
      );
    }).toList();
  }

  static List<RotatePieBuildingInfo> get data => getBuildingInfo (dataSets, total);
}