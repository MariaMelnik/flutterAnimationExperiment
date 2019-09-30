import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/pie_chart.dart';
import 'package:flutter_gauge_test/expandedPieChart/rotate_pie_data_set.dart';
import 'package:flutter_gauge_test/expandedPieChart/styled_tab_view.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_indicator.dart';

class RotatePie extends StatefulWidget {
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

  const RotatePie({
    Key key,
    @required this.buildingInfo,
    double heightReduction
  }) : assert (buildingInfo != null),
       this.heightReduction = heightReduction ?? 0.0,
       super(key: key);

  @override
  _RotatePieState createState() => _RotatePieState();
}

class _RotatePieState extends State<RotatePie> with TickerProviderStateMixin {
  // Size of the pie when it is on top. 
  // It is the smallest size pie can be.
  final double _pieHeightAfterClick = 200.0;

  final Curve _curve = Curves.easeOut;

  Duration _animationDuration = const Duration(milliseconds: 400);

  // Controller for pie size animation when user scroll up tabs and for turn animation as well.
  AnimationController _controller;
  
  // Controller for sliver app bar size animation after user clicked on big pie.
  AnimationController _pieSliverHeightController;

  // Controller for pie chart size animation.
  AnimationController _pieSizeController;

  Animation<double> _turnAnimation;
  
  Animation<double> _pieSizeAnimation;
  
  Animation<double> _pieSliverHeightAnimation;
  
  TabController _tabController;
  
  PieChartSector _currentSector;

  // true is animation is initialized by tab on circle
  // needs to avoid animation caused tab switching while circle is rotating
  bool _isCircleInitializedAnimationGoing = false;

  // Angle of last rotation. Should be between 0 and 2 * pi.
  double _lastRotationVal = 0.0;

  // Map where key is PieChartSector and value is angle of the middle of this sector.
  Map<PieChartSector, double> _sectorMiddles = Map<PieChartSector, double>();

  double _maxShownAngle = 0.0;

  double _lastTabControllerAnimationValue = 0.0;

  @override
  void initState(){
    super.initState();

    _controller = AnimationController(duration: _animationDuration, vsync: this);
    _pieSliverHeightController = AnimationController(duration: _animationDuration, vsync: this);
    _pieSizeController = AnimationController(duration: _animationDuration, vsync: this);

    // Made fake animation here because we use one _controller for two animations.
    // Both of them must not be null when controller forwards.
    _turnAnimation = Tween(begin: 0.0, end: 0.0).animate(_controller);
    _pieSizeAnimation = Tween(begin: 1.0, end: 0.7).animate(_pieSizeController);

    _tabController = TabController(length: widget.buildingInfo.length, vsync: this);
    _tabController.addListener(_tabControllerChanged);
    _tabController.animation.addListener(_changeRotation);

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _startInitialFillAnimation());
  }

  // todo: refactor this
  void _changeRotation(){

    bool ltr = _tabController.animation.value > _lastTabControllerAnimationValue;
    int page = ltr ? _tabController.animation.value.floor() : _tabController.animation.value.ceil();
    int nextPage = ltr ? page + 1: page - 1;

    _lastTabControllerAnimationValue = _tabController.animation.value;

    if (nextPage < 0 || nextPage > widget.buildingInfo.length - 1) return;

    List<RotatePieBuildingInfo> reversedList = List.from(widget.buildingInfo.reversed);
    double middleFrom = _sectorMiddles[reversedList[page].sector];
    double middleTo = _sectorMiddles[reversedList[nextPage].sector];

    bool differentSignAngle = middleFrom * middleTo < 1;
    double needPass = differentSignAngle
        ? (middleFrom.abs() + middleTo.abs()).abs()
        : (middleFrom.abs() - middleTo.abs()).abs();
    double alreadyPassed = needPass * (_tabController.animation.value - page).abs();

    double newRotation = ltr
        ? middleFrom + alreadyPassed
        : middleFrom - alreadyPassed;

    setState(() {
      _lastRotationVal = newRotation;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    double height = MediaQuery.of(context).size.height - widget.heightReduction;
    _initSetAnimation(height);
    _initSectorsMiddles();
  }

  void _initSectorsMiddles() {
    _sectorMiddles.clear();

    widget.buildingInfo
        .forEach((RotatePieBuildingInfo info) {
            double originalMiddle = (info.sector.startAngle + info.sector.endAngle) / 2;
            double rotatedMiddle = pi/2 - originalMiddle;
            _sectorMiddles[info.sector] = rotatedMiddle;
          });

    print("sector middles:");
    _sectorMiddles.forEach((k, v) => print("For color ${k.color} middle is $v"));
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

  void _tabControllerChanged() {
    PieChartSector targetSector = widget.buildingInfo[_tabController.length -1  - _tabController.index].sector;
    if (targetSector != _currentSector) {
      print("_tabControllerChanged:: targetSector is: ${targetSector.color}");
      if (!_isCircleInitializedAnimationGoing) _rotateToCenterOfSector(targetSector);
      _currentSector = targetSector;
    }
  }

  Widget _buildPie(){
    return Center(
      child: LayoutBuilder(
          builder: (bcontext, _) {
            return AnimatedBuilder(
              animation: _pieSizeAnimation,
              builder: (_,__) => Transform.scale(
                  scale: _pieSizeAnimation.value,
                  child: AnimatedBuilder(
                      animation: _turnAnimation,
                      builder: (_, __) => Transform.rotate(
                        angle: _turnAnimation.value,
                        child: _buildTapablePie(bcontext),
                      )
                  )
              ),
            );
          }
      ),
    );
  }

  //we need relative context from LayoutBuilder here to get relative coordinates of user's tap
  Widget _buildTapablePie(BuildContext context){
    return GestureDetector(
      child: PieChart(
        sectors: widget.buildingInfo.map((info) => info.sector).toList(),
        rotateAngle: _lastRotationVal,
        selectedSector: _currentSector,
        maxShowAngle: _maxShownAngle,
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
      tabController: _tabController,
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

    PieChartSector targetSector = _findTargetSector(angle, _lastRotationVal);
    if (targetSector == null) return null;

    if (targetSector != _currentSector) {
      int index = widget.buildingInfo.indexWhere((info) => info.sector == targetSector);

      // duration must be the same as duration of circle rotation animation
      _tabController.animateTo(_tabController.length - 1 - index, duration: _animationDuration, curve: _curve);
      _rotateToCenterOfSector(targetSector);

      _currentSector = targetSector;
    }
  }
  
  void _rotateToCenterOfSector(PieChartSector sector) {
    setState(() {
      _lastRotationVal = _sectorMiddles[sector];
    });
  }

  double _normalize(double originalVal) {
    return originalVal % (2*pi);
  }
}
