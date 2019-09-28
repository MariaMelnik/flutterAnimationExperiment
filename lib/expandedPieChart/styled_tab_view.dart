import 'package:flutter/material.dart';
import 'package:flutter_gauge_test/expandedPieChart/tab_indicator.dart';
import 'package:flutter_gauge_test/expandedPieChart/triangle_clipper.dart';

class StyledTabView extends StatefulWidget {
  final List<TabIndicator> tabs;

  // Children for TabBarView widget.
  final List<Widget> children;
  final TabController tabController;

  const StyledTabView({
    Key key,
    @required this.tabs,
    @required this.tabController,
    @required this.children
  })
      : assert(tabController != null),
        assert(children != null),
        super(key: key);

  @override
  _StyledTabViewState createState() => _StyledTabViewState();
}

class _StyledTabViewState extends State<StyledTabView> {
  Color _currentColor;
  double _lastTabControllerAnimationPosition = 0.0;

  @override
  void initState() {
    super.initState();

    _currentColor = widget.tabs.first.color;
    widget.tabController.animation.addListener(_changeTabColor);
  }

  void _changeTabColor(){
    bool ltr = widget.tabController.animation.value > _lastTabControllerAnimationPosition;
    int page = widget.tabController.animation.value.floor();
    int nextPage = ltr ? page + 1: page - 1;

    if (nextPage < 0 || nextPage > widget.tabs.length - 1) return;

    Color colorFrom = widget.tabs[page].color;
    Color colorTo = widget.tabs[nextPage].color;

    setState(() {
      _currentColor = Color.lerp(colorFrom, colorTo, widget.tabController.animation.value - page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar(
          tabs: widget.tabs,
          isScrollable: true,
          controller: widget.tabController,
        ),
        Expanded(
            child: Column(
              children: <Widget>[
                SizedBox(height: 10.0,),
                Center(
                  child: ClipPath(
                    clipper: TriangleClipper(),
                    child: Container(
                      height: 10.0,
                      width: 20.0,
                      color: _currentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _currentColor,
                    ),
                    child: TabBarView(
                      children: widget.children,
                      controller: widget.tabController,
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }
}
