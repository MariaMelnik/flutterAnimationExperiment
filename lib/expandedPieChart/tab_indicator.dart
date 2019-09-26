import 'package:flutter/material.dart';

const double kTabIndicatorHeight = 18.0;

class TabIndicator extends StatelessWidget {
  final Color color;

  const TabIndicator({Key key, @required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kTabIndicatorHeight,
      width: 120.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: color
      ),
    );
  }
}