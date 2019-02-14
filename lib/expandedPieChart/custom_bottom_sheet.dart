import 'package:flutter/material.dart';

class CustomBottomSheet extends StatelessWidget {
  final Color color;

  const CustomBottomSheet({Key key, @required this.color}) : super(key: key);

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
          Expanded(child: Container(color: color,),)
        ],
      ),
    );
  }
}

//fixme: check how it works
class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width / 2, 0.0);
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(TriangleClipper oldClipper) => false;
}
