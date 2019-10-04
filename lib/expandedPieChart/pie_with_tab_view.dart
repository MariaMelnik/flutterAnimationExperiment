import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie_data_set.dart';
import 'package:flutter_gauge_test/expandedPieChart/styled_tab_view.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_indicator.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_pie_chart_controller.dart';

class PieWithTabView extends StatefulWidget {
  final List<RotatePieBuildingInfo> buildingInfo;

  /// How much view port for initial pie chart less than screen height.
  ///
  /// If you have appBar - it is 64.0.
  /// If null - no reduction will be used. Height of view port for pie chart will be equals screen height.

  // As long as pie is scrollable we don't know appropriate initial size for it to match it free screen.
  // We can't get it with context because it is scrollable as well.
  // By default we make view port height equals screen height.
  // But if user has app bar it mean not all pieChart will be pushed at the bottom little bit by this appBar.
  // To make it center and correct size we need to know heights of all widgets user use on the same screen as pie chart.
  final double heightReduction;

  const PieWithTabView({
    Key key,
    @required this.buildingInfo,
    double heightReduction
  }) : assert (buildingInfo != null),
       this.heightReduction = heightReduction ?? 0.0,
       super(key: key);

  @override
  _PieWithTabViewState createState() => _PieWithTabViewState();
}

class _PieWithTabViewState extends State<PieWithTabView> with TickerProviderStateMixin {
  // Size of the pie when it is on top. 
  // It is the smallest size pie can be.
  final double _pieHeightAfterClick = 200.0;

  final Curve _curve = Curves.easeOut;

  Duration _animationDuration = const Duration(milliseconds: 400);

  // Controller for sliver app bar size animation after user clicked on big pie.
  AnimationController _pieSliverHeightController;

  // Controller for pie chart size animation.
  AnimationController _pieSizeController;

  Animation<double> _pieSizeAnimation;
  
  Animation<double> _pieSliverHeightAnimation;
  
  TabPieChartController _myController;

  double _maxShownAngle = 0.0;

  @override
  void initState(){
    super.initState();

    _pieSliverHeightController = AnimationController(duration: _animationDuration, vsync: this);
    _pieSizeController = AnimationController(duration: _animationDuration, vsync: this);

    _pieSizeAnimation = Tween(begin: 1.0, end: 0.7).animate(_pieSizeController);

    var tabController = TabController(length: widget.buildingInfo.length, vsync: this);
    _myController = TabPieChartController(tabController: tabController, buildingInfo: widget.buildingInfo);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startInitialFillAnimation());
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double height = MediaQuery.of(context).size.height - widget.heightReduction;
    _initSetAnimation(height);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        AnimatedBuilder(
          animation: _pieSliverHeightAnimation,
          child: _buildPie(),
          builder: (_, Widget child) => SliverAppBar(
            floating: false,
            flexibleSpace: child,
            expandedHeight: _pieSliverHeightAnimation.value,
            backgroundColor: Colors.transparent,
            pinned: false,
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate.fixed([_buildTabViews()])
        )
      ],
    );
  }

  // We need change angle after first build delay to make implicit animation work for initial filling chart.
  void _startInitialFillAnimation(){
    setState(() => _maxShownAngle = 2*pi);
  }

  Widget _buildPie(){
    return Center(
      child: LayoutBuilder(
          builder: (bcontext, _) {
            return AnimatedBuilder(
              animation: _pieSizeAnimation,
              builder: (_,__) => Transform.scale(
                  scale: _pieSizeAnimation.value,
                  child: _buildTapablePie(bcontext)
              ),
            );
          }
      ),
    );
  }

  //we need relative context from LayoutBuilder here to get relative coordinates of user's tap
  Widget _buildTapablePie(BuildContext context){
    return GestureDetector(
      child: StreamBuilder<double>(
        stream: _myController.rotationStream,
        initialData: _myController.lastRotationVal,
        builder: (context, AsyncSnapshot<double> snapshot) {
          return StreamBuilder<double>(
            stream: _myController.selectedSectorOpacityStream,
            initialData: _myController.lastOpacityVal,
            builder: (context, AsyncSnapshot<double> opacitySnapshot) {
              return RotatedPieChart(
                sectors: widget.buildingInfo.map((info) => info.sector).toList(),
                selectedSector: _myController.selectedSector,
                previousSelectedSector: _myController.previousSelectedSector,
                rotateAngle: snapshot.data,
                maxShowAngle: _maxShownAngle,
                selectedOpacityDelta: opacitySnapshot.data,
              );
            }
          );
        }
      ),
      onTapUp: (details) => _onTap(details, context),
    );
  }

  Widget _buildTabViews(){
    List<Widget> children = widget.buildingInfo
        .map((info) => Container(child: info.child,))
        .toList().reversed.toList();

    List<Widget> tabs = widget.buildingInfo
        .map((info) => TabIndicator(color: info.color))
        .toList().reversed.toList();

    Widget styledTabView = StyledTabView(
      children: children,
      tabs: tabs,
      tabController: _myController.tabController,
    );

    double height = MediaQuery.of(context).size.height - widget.heightReduction - kTabIndicatorHeight;

    return Container(
      height: height,
      width: double.infinity,
      child: styledTabView
    );
  }


  void _initSetAnimation(double height){
    _pieSliverHeightAnimation = Tween(begin: height, end: _pieHeightAfterClick).animate(_pieSliverHeightController);
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
    _pieSliverHeightController.forward();
    _pieSizeController.forward();

//    _isCircleInitializedAnimationGoing = true;

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

    PieChartSector targetSector = _findTargetSector(angle, _myController.lastRotationVal);
    if (targetSector == null) return;

    int targetSectorIndex = widget.buildingInfo.indexWhere((info) => info.sector == targetSector);
    int curSectorIndex = _myController.tabController.index;

//    if (targetSectorIndex == curSectorIndex) return;
    _myController.tabController.animateTo(_myController.tabController.length - 1 - targetSectorIndex, duration: _animationDuration, curve: _curve);
  }


  double _normalize(double originalVal) {
    return originalVal % (2*pi);
  }
}
