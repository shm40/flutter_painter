import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter_state.dart';

class PainterController extends ValueNotifier<FlutterPainterState> {
  PainterController() : super(const FlutterPainterState());

  /// Add start positin when dragging start
  void add(Offset startPosition) {
    // Ignore to add path in current path histories if in drag
    if (value.inDrag) {
      return;
    }

    // Define the paint to draw
    final paint = Paint()..style = PaintingStyle.stroke;

    // If the current mode is erasing, set the erase setting to paint
    if (value.eraseMode) {
      paint.color = Colors.transparent;
      paint.blendMode = BlendMode.clear;
      paint.strokeWidth = value.eraseStrokeWidth;
    } else {
      paint.color = Colors.black;
      paint.strokeWidth = value.strokeWidth;
    }

    value = value.copyWith(
      currentOffset: startPosition,
      inDrag: true,
      paths: [
        ...value.paths,
        MapEntry(Path()..moveTo(startPosition.dx, startPosition.dy), paint),
      ],
    );

    notifyListeners();
  }

  /// Update dragging position
  void update(Offset currentPosition) {
    // Ignore when not dragging or when current path history is empty
    if (!value.inDrag || value.paths.isEmpty) {
      return;
    }

    // Update the last path position
    value.paths.last.key.lineTo(currentPosition.dx, currentPosition.dy);

    // Update current position
    value = value.copyWith(currentOffset: currentPosition);

    notifyListeners();
  }

  /// End dragging
  void end() {
    value = value.copyWith(inDrag: false);

    // Reset current drawing offset
    value = value.copyWith(currentOffset: Offset.zero);

    notifyListeners();
  }

  /// Change dragging mode to erasing or not erasing
  void toggleEraseMode() {
    value = value.copyWith(eraseMode: !value.eraseMode);
    notifyListeners();
  }

  /// Change stroke width when dragging
  void changeStrokeWidth(double strokeWidth) {
    value = value.copyWith(strokeWidth: strokeWidth);
    notifyListeners();
  }

  /// Change erase stroke width when dragging
  void changeEraseStrokeWidth(double eraseStrokeWidth) {
    value = value.copyWith(eraseStrokeWidth: eraseStrokeWidth);
    notifyListeners();
  }

  /// Change line color when drawing
  void changeLineColor(Color newColor) {
    value = value.copyWith(lineColor: newColor);
    notifyListeners();
  }

  /// Draw current stored paths to canvas
  void draw(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    for (final element in value.paths) {
      canvas.drawPath(element.key, element.value);
    }
    canvas.restore();
  }
}
