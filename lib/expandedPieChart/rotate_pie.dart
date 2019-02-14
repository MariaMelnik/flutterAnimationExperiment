import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/custom_bottom_sheet.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_indicator.dart';

class RotatePie extends StatefulWidget {
  const RotatePie({Key key}) : super(key: key);

  @override
  _RotatePieState createState() => _RotatePieState();
}

class _RotatePieState extends State<RotatePie> with TickerProviderStateMixin {
  static const List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.grey,
    Colors.green
  ];

  static const List<PieChartSector> sectors = [
    PieChartSector(startAngle: 0.0, endAngle: pi/2, color: Colors.red, sectorWidth: 180.0),
    PieChartSector(startAngle: pi/2, endAngle: pi, color: Colors.yellow, sectorWidth: 180.0),
    PieChartSector(startAngle: pi, endAngle: pi+pi/2, color: Colors.grey, sectorWidth: 180.0),
    PieChartSector(startAngle: pi+pi/2, endAngle: 2*pi, color: Colors.green, sectorWidth: 180.0),
  ];

  AnimationController controller;
  Animation<double> turnAnimation;
  Animation<double> pieSizeAnimation;
  Animation<double> bottomContainerSizeAnimation;
  double _lastAnimationVal = 0.0;

  Animation<double> pieDyOffsetAnimation;
  final double targetDyOffset = -250.0;
  final double maxContainerHeight = 450.0;

  @override
  void initState(){
    super.initState();

    controller = AnimationController(duration: Duration(seconds: 1), vsync: this);
    turnAnimation = Tween(begin: 0.0, end: 0.0).animate(controller);
    pieSizeAnimation = Tween(begin: 1.0, end: 0.5).animate(controller);
    pieDyOffsetAnimation = Tween(begin: 0.0, end: targetDyOffset).animate(controller);

    bottomContainerSizeAnimation = Tween(begin: 0.0, end: maxContainerHeight).animate(controller);
  }


  //we need relative context from LayoutBuilder here to get relative coordinates of user's tap
  Widget _buildTapablePie(BuildContext context){
    return GestureDetector(
      child: PieChart(
        sectors: sectors,
      ),
      onTapUp: (details) => _onTap(details, context),
    );
  }

  Widget _buildPie(){
    return Center( //todo: I am not sure Center should be inside this widget, not outside
      child: AnimatedBuilder(
        animation: pieDyOffsetAnimation,
        builder: (_, __) => Transform.translate(
          offset: Offset(0.0, pieDyOffsetAnimation.value),
          child: LayoutBuilder(
              builder: (bcontext, _) {
                return RotationTransition(
                    turns: turnAnimation,
                    child: AnimatedBuilder(
                      animation: pieSizeAnimation,
                      builder: (_, __) => Transform.scale(
                          scale: pieSizeAnimation.value,
                          child: _buildTapablePie(bcontext)
                      ),
                    )
                );
              }
          ),
        ),
      ),
    );
  }

  Widget _buildBottomContainer(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedBuilder(
        animation: bottomContainerSizeAnimation,
        builder: (_, __ ) => _buildTabViews(),
      ),
    );
  }

  Widget _buildTabViews(){
    List<Widget> children = List<Widget>();
    colors.forEach((Color color) => children.add(CustomBottomSheet(color: color)));


    List<Widget> tabs = List<Widget>();
    colors.forEach((Color color) => tabs.add(TabIndicator(color: color)));


    return Container(
      height: bottomContainerSizeAnimation.value,
      width: double.infinity,
      child: DefaultTabController(
          length:4,
          child: Column(
            children: <Widget>[
              TabBar(tabs: tabs, isScrollable: true,),
              Expanded(child: TabBarView(children: children)),
            ],
          )
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _buildBottomContainer(),
        _buildPie(),
      ],
    );
  }

  PieChartSector _findTargetSector(double angle, double rotationFromInitAngle){
    return sectors.firstWhere((PieChartSector sector) {
      bool isTapped = false;

      double rotatedStart =  sector.startAngle - rotationFromInitAngle;
      double rotatedEnd = sector.endAngle - rotationFromInitAngle;

      if (rotatedStart < 0 && rotatedEnd < 0) {
        rotatedStart = rotatedStart + 2*pi;
        rotatedEnd = rotatedEnd + 2*pi;

        isTapped = rotatedStart <= angle && rotatedEnd >= angle;
      } else if (rotatedStart < 0) {
        rotatedStart = rotatedStart + 2*pi;

        //split one sector for two
        double startFirstSector = rotatedStart;
        double endFirstSector = 2*pi;

        double startSecondSector = 0;
        double endSecondSector = rotatedEnd;

        bool isFirstSectorTapped = startFirstSector <= angle && endFirstSector >= angle;
        bool isSecondSectorTapped = startSecondSector <= angle && endSecondSector >= angle;

        isTapped = isFirstSectorTapped || isSecondSectorTapped;
      } else {
        isTapped = rotatedStart <= angle && rotatedEnd >= angle;
      }

      return isTapped;
    }, orElse: ()=>null);
  }


  //how much we should rotate to the middle of the targetSector
  double _findCenterToRotate(PieChartSector targetSector, double rotationFromInitAngle){
    double sectorAngleFromStartToMiddle = (targetSector.endAngle - targetSector.startAngle)/2;
    double rotatedStart = targetSector.startAngle - rotationFromInitAngle;
    double angleToRotateToMiddle = rotatedStart + sectorAngleFromStartToMiddle;
    if (angleToRotateToMiddle < 0) angleToRotateToMiddle = angleToRotateToMiddle + 2*pi;

    return angleToRotateToMiddle;
  }


  void _onTap(TapUpDetails details, BuildContext context){
    print("onTap");

    Offset tapPosition = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);


    Size boxSize = (context.findRenderObject() as RenderBox).size;

    //finding angle with tangens
    double radius = boxSize.width/2;
    double a = tapPosition.dx - radius;
    double b = tapPosition.dy - radius;
    double angle = atan2(a, b);
    if(tapPosition.dx < radius) {
      //atan2 gives us value in [-pi, pi]. We need convert negative value to positive
      angle = angle + 2*pi;
    }

    PieChartSector targetSector = _findTargetSector(angle, _lastAnimationVal*2*pi);
    if (targetSector == null) return null;

    double angleToRotateToMiddleOfSector = _findCenterToRotate(targetSector, _lastAnimationVal*2*pi);
    double oldVal = _lastAnimationVal;
    double endVal = _lastAnimationVal + angleToRotateToMiddleOfSector/(2*pi);

    setState(() {
      CurvedAnimation curve = CurvedAnimation(parent: controller, curve: Curves.easeIn);
      turnAnimation = Tween(begin: oldVal, end: endVal).animate(curve);
    });

    controller.reset();
    controller.forward().then((_) {
      _lastAnimationVal = endVal;
      if (_lastAnimationVal > 1) _lastAnimationVal = _lastAnimationVal - 1;
    });
  }
}
