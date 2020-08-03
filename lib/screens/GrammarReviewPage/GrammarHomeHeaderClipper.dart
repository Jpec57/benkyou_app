import 'package:flutter/material.dart';

class GrammarHomeHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.lineTo(0, size.height * 0.70); //vertical line
    path.cubicTo(size.width / 3, size.height, 2 * size.width / 3,
        size.height * 0.5, size.width, size.height * 0.80); //cubic curve
    path.lineTo(size.width, 0); //vertical line
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/*
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.red;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    double yUp = 0.6 * size.height;
    path.moveTo(0, 0);
    path.lineTo(0, yUp);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, yUp);
    path.lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }
 */
