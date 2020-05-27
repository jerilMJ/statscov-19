import 'package:flutter/material.dart';

class FlippableCardFrontDesign extends CustomPainter {
  const FlippableCardFrontDesign(this.color, this.secondaryColor);
  final Color color;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = secondaryColor;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width * 0.95, size.height / 2),
            width: size.width * 0.025,
            height: size.height / 2,
          ),
          const Radius.circular(5.0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(FlippableCardFrontDesign oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(FlippableCardFrontDesign oldDelegate) => false;
}

class FlippableCardBackDesign extends CustomPainter {
  const FlippableCardBackDesign(this.color, this.secondaryColor);
  final Color color;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = secondaryColor;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width - size.width * 0.95, size.height / 2),
            width: size.width * 0.025,
            height: size.height / 2,
          ),
          const Radius.circular(5.0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(FlippableCardFrontDesign oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(FlippableCardFrontDesign oldDelegate) => false;
}
