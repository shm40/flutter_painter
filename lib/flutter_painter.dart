import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter_controller.dart';

class FlutterPainter extends CustomPainter {
  final PainterController _painterController;
  FlutterPainter(this._painterController, {Listenable? repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _painterController.draw(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
