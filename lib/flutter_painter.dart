import 'package:flutter/material.dart';

class FlutterPainter extends CustomPainter {
  final FlutterPainterController _painterController;
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

class FlutterPainterController extends ChangeNotifier {
  final List<MapEntry<Path, Paint>> _paths = [];
  bool _inDrag = false;
  bool _eraseMode = false;

  void add(Offset startPosition) {
    if (_inDrag) {
      return;
    }
    final paint = Paint()
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.srcOver;

    if (_eraseMode) {
      paint.color = Colors.white;
      paint.blendMode = BlendMode.clear;
      paint.strokeWidth = 48;
    }

    _paths.add(
      MapEntry(
        Path()..moveTo(startPosition.dx, startPosition.dy),
        paint,
      ),
    );
    _inDrag = true;
    notifyListeners();
  }

  void update(Offset currentPosition) {
    if (_paths.isEmpty || !_inDrag) {
      return;
    }
    _paths.last.key.lineTo(currentPosition.dx, currentPosition.dy);

    notifyListeners();
  }

  void end() {
    _inDrag = false;

    notifyListeners();
  }

  void changeEraseMode() {
    _eraseMode = !_eraseMode;
  }

  void draw(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (var element in _paths) {
      canvas.drawPath(element.key, element.value);
    }
    canvas.restore();
  }
}
