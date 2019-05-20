import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/custom_bottom_sheet.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie_data_set.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_indicator.dart';

class RotatePie extends StatefulWidget {
  final List<RotatePieBuildingInfo> buildingInfo;

  const RotatePie({
    Key key,
    @required this.buildingInfo,
  }) : assert (buildingInfo != null),
       super(key: key);

  @override
  _RotatePieState createState() => _RotatePieState();
}

class _RotatePieState extends State<RotatePie> with TickerProviderStateMixin {
  bool onTop = false;
  AnimationController controller;
  AnimationController pieSliverHeightController;
  Animation<double> turnAnimation;
  Animation<double> pieSizeAnimation;
  Animation<double> pieSliverHeightAnimation;
  TabController tabController;
  PieChartSector _currentSector;

  Duration _animationDuration = const Duration(milliseconds: 400);
  Curve _curve = Curves.easeOut;

  // true is animation is initialized by tab on circle
  // needs to avoid animation caused tab switching while circle is rotating
  bool _isCircleInitializedAnimationGoing = false;


  double _lastAnimationVal = 0.0; //angle of last rotation

  final double pieHeightAfterClick = 200.0;

  @override
  void initState(){
    super.initState();

    controller = AnimationController(duration: _animationDuration, vsync: this);
    pieSliverHeightController = AnimationController(duration: _animationDuration, vsync: this);
    turnAnimation = Tween(begin: 0.0, end: 0.0).animate(controller);
    pieSizeAnimation = Tween(begin: 1.0, end: 0.7).animate(controller);

    tabController = TabController(length: widget.buildingInfo.length, vsync: this);
    tabController.addListener(_tabControllerChanged);
  }

  void _tabControllerChanged() {
    PieChartSector targetSector = widget.buildingInfo[tabController.length -1  - tabController.index].sector;
    if (targetSector != _currentSector) {
      print("_tabControllerChanged:: targetSector is: ${targetSector.color}");
      if (!_isCircleInitializedAnimationGoing) _rotateToCenterOfSector(targetSector);
      _currentSector = targetSector;
    }
  }

  //we need relative context from LayoutBuilder here to get relative coordinates of user's tap
  Widget _buildTapablePie(BuildContext context){
    return GestureDetector(
      child: PieChart(
        sectors: widget.buildingInfo.map((info) => info.sector).toList(),
      ),
      onTapUp: (details) => _onTap(details, context),
    );
  }

  Widget _buildPie(){
    return Center( //todo: I am not sure Center should be inside this widget, not outside
      child: LayoutBuilder(
          builder: (bcontext, _) {
            return AnimatedBuilder(
              animation: pieSizeAnimation,
              builder: (_,__) => RotationTransition(
                  turns: turnAnimation,
                  child: AnimatedBuilder(
                    animation: pieSizeAnimation,
                    builder: (_, __) => Transform.scale(
                        scale: pieSizeAnimation.value,
                        child: _buildTapablePie(bcontext)
                    ),
                  )
              ),
            );
          }
      ),
    );
  }

  Widget _buildBottomContainer(){
    return Align(
      alignment: Alignment.bottomCenter,
      child: _buildTabViews()
    );
  }

  Widget _buildTabViews(){
    List<Widget> children = widget.buildingInfo
        .map((info) => CustomBottomSheet(color: info.color))
        .toList().reversed.toList();

    List<Widget> tabs = widget.buildingInfo
        .map((info) => TabIndicator(color: info.color))
        .toList().reversed.toList();

    //fixme: calculate correct size according to appBar size and tabBar size
    double height = MediaQuery.of(context).size.height;

    return Container(
      height: height,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: tabs,
            isScrollable: true,
            controller: tabController,
          ),
          Expanded(
              child: TabBarView(
                children: children,
                controller: tabController,
              )
          ),
        ],
      ),
    );
  }

  void _initSetAnimation(double height){
    pieSliverHeightAnimation = Tween(begin: height-100, end: pieHeightAfterClick).animate(pieSliverHeightController);
  }

  @override
  Widget build(BuildContext context) {
    if(pieSliverHeightAnimation == null) {
      double height = MediaQuery.of(context).size.height;
      _initSetAnimation(height);
    }

    return CustomScrollView(
      slivers: <Widget>[
//          SliverAppBar(
//            floating: false,
//            flexibleSpace: _buildPie(),
//            expandedHeight: 600,
//            backgroundColor: Colors.transparent,
//            pinned: false,
//          ),
        AnimatedBuilder(
          animation: pieSliverHeightAnimation,
          builder: (_, __) => SliverAppBar(
            floating: false,
            flexibleSpace: _buildPie(),
            expandedHeight: pieSliverHeightAnimation.value,
            backgroundColor: Colors.transparent,
            pinned: false,
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([_buildBottomContainer()])
        )
      ],
    );
  }

  PieChartSector _findTargetSector(double angle, double rotationFromInitAngle){
    var relTapAngle = angle - rotationFromInitAngle;
    relTapAngle = _normalize(relTapAngle);

    List<PieChartSector> sectors = widget.buildingInfo.map((info) => info.sector).toList();
    
    return sectors.firstWhere((PieChartSector sector) {
      return sector.startAngle <= relTapAngle && sector.endAngle > relTapAngle;
    }, orElse: ()=>null);
  }
  

  void _onTap(TapUpDetails details, BuildContext context) {
    pieSliverHeightController.forward();

    _isCircleInitializedAnimationGoing = true;

    Offset tapPosition = (context.findRenderObject() as RenderBox).globalToLocal(details.globalPosition);
    Size boxSize = (context.findRenderObject() as RenderBox).size;

    //finding angle with tangens
    double radius = boxSize.width/2;
    double a = tapPosition.dx - radius;
    double b = tapPosition.dy - radius;
    double angle = atan2(b, a);
    if(tapPosition.dy < radius) {
      //atan2 gives us value in [-pi, pi]. We need convert negative value to positive
      angle = angle + 2*pi;
    }

    PieChartSector targetSector = _findTargetSector(angle, _lastAnimationVal * 2 * pi);
    if (targetSector == null) return null;

    if (targetSector != _currentSector) {
      int index = widget.buildingInfo.indexWhere((info) => info.sector == targetSector);

      // duration must be the same as duration of circle rotation animation
      tabController.animateTo(tabController.length - 1 - index, duration: _animationDuration, curve: _curve);
      _rotateToCenterOfSector(targetSector);

      _currentSector = targetSector;
    }
  }
  
  void _rotateToCenterOfSector(PieChartSector sector) {
    double sectorMiddle = (sector.endAngle + sector.startAngle) / 2;
    double newCircleAngle = _normalize(pi/2 - sectorMiddle);
    double oldNormAngle = _normalize(_lastAnimationVal * 2 * pi);
//    if (newCircleAngle < oldNormAngle) newCircleAngle += 2 * pi;
    double delta = newCircleAngle - oldNormAngle;

    double endValRad = _lastAnimationVal * 2 * pi + delta;
    double oldVal = _lastAnimationVal;

    CurvedAnimation curve = CurvedAnimation(parent: controller, curve: _curve);
    turnAnimation = Tween(begin: oldVal, end: endValRad / (2*pi)).animate(curve);

    controller.reset();
    controller.forward().then((_) {
      _lastAnimationVal = endValRad / (2*pi);
      _isCircleInitializedAnimationGoing = false;
    });
  }

  double _normalize(double originalVal) {
    return originalVal % (2*pi);
  }
}
