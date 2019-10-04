import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart_sector.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie_data_set.dart';
import 'dart:math';

/// Controller for connecting changes of the pie chart and tab view.

// [buildingInfo.sectors] length must be equals [tabController.length]
class TabPieChartController {
  final TabController tabController;
  final List<RotatePieBuildingInfo> buildingInfo;

  // Stream for rotation of the pie chart according to [tabController.animation] value.
  Stream<double> get rotationStream => _rotationController.stream;
  double get lastRotationVal => _lastRotationVal;

  Stream<double> get selectedSectorOpacityStream => _opacityController.stream;
  double get lastOpacityVal => _lastOpacityVal;

  PieChartSector get selectedSector =>  buildingInfo[buildingInfo.length - 1 - _selectedIndex].sector;
  PieChartSector get previousSelectedSector =>  buildingInfo[buildingInfo.length - 1 - _previousSelectedIndex].sector;

  TabPieChartController({
    @required this.tabController,
    @required this.buildingInfo
  })
      : assert(tabController != null),
        assert(buildingInfo != null)
  {
    tabController.animation.addListener(_controllerAnimationChanged);
    _initSectorsMiddles();
  }

  void _initSectorsMiddles() {
    _sectorMiddles.clear();

    buildingInfo
        .forEach((RotatePieBuildingInfo info) {
      double originalMiddle = (info.sector.startAngle + info.sector.endAngle) / 2;
      double rotatedMiddle = pi/2 - originalMiddle;
      _sectorMiddles[info.sector] = rotatedMiddle;
    });
  }

  void _controllerAnimationChanged() {
    if (tabController.animation.value % 1 == 0) return;

    if (tabController.index == tabController.previousIndex) return;

    bool ltr = _previousTabControllerVal < tabController.animation.value;
    _previousSelectedIndex = ltr ? tabController.animation.value.floor() : tabController.animation.value.ceil();
    _selectedIndex = ltr ? _previousSelectedIndex + 1: _previousSelectedIndex - 1;

    _previousTabControllerVal = tabController.animation.value;

    if (_selectedIndex < 0 || _selectedIndex > buildingInfo.length - 1) return;

    List<RotatePieBuildingInfo> reversedList = List.from(buildingInfo.reversed);
    double middleFrom = _sectorMiddles[reversedList[_previousSelectedIndex].sector];
    double middleTo = _sectorMiddles[reversedList[_selectedIndex].sector];

    bool differentSignAngle = middleFrom * middleTo < 1;
    double needPass = differentSignAngle
        ? (middleFrom.abs() + middleTo.abs()).abs()
        : (middleFrom.abs() - middleTo.abs()).abs();
    double alreadyPassed = needPass * (tabController.animation.value - _previousSelectedIndex).abs();

    // new rotation
    double newRotation = ltr
        ? middleFrom + alreadyPassed
        : middleFrom - alreadyPassed;

    _rotationController.add(newRotation);
    _lastRotationVal = newRotation;

    // new opacity delta
    var newSelectedOpacity = ltr
        ? (tabController.animation.value % 1) / 2
        : (1 - tabController.animation.value % 1) / 2;

    _opacityController.add(newSelectedOpacity);
    _lastOpacityVal = newSelectedOpacity;
  }


  void dispose(){
    _rotationController.close();
    _opacityController.close();
    tabController.animation.removeListener(_controllerAnimationChanged);
  }

  // Map where key is PieChartSector and value is angle of the middle of this sector.
  Map<PieChartSector, double> _sectorMiddles = Map<PieChartSector, double>();

  StreamController<double> _rotationController = StreamController<double>.broadcast();

  // Controller for the opacity of the selected sector.
  StreamController<double> _opacityController = StreamController<double>.broadcast();

  // Angle of last rotation. Should be between 0 and 2 * pi.
  double _lastRotationVal = 0.0;

  // Delta between 1 and opacityThreashold for selectedSector. Should be between 0 and 0.5.
  double _lastOpacityVal = 0.0;

  // We need it for correct track direction of move tabs.
  // If we will use [tabController.index] it will work only when we do [tabController.animateTo].
  // If user is sliding tabs index will be changed only at the end of movement. It can cause errors.
  double _previousTabControllerVal = 0.0;
  
  // Index of the selected sector in [buildingInfo].
  // While there is some moving this is the index of page "to".
  int _selectedIndex = 0;

  // Index of the selected sector in [buildingInfo].
  // While there is some moving this is the index of page "from".
  int _previousSelectedIndex = 0;
}