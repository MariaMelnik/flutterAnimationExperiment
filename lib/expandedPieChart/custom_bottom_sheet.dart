import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  /// Background color for the container.
  final Color color;

  /// Child widget inside container.
  final Widget child;

  const CustomBottomSheet({Key key, @required this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: <Widget>[
          Center(
            child: ClipPath(
              clipper: TriangleClipper(),
              child: Container(
                height: 10.0,
                width: 20.0,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: color,
              child: child,
            ),
          )
        ],
      ),
    );
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0.0);
    path.lineTo(0.0, size.height + 1.0); // Add 1.0 to cover 1.0 strokeWidth
    path.lineTo(size.width, size.height + 1.0); //  Add 1.0 to cover 1.0 strokeWidth
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
