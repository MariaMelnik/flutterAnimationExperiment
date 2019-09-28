import 'package:flutter/material.dart';

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