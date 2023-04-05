import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
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
      paint.color = value.lineColor;
      paint.strokeWidth = value.strokeWidth;
      paint.strokeCap = StrokeCap.round;
      paint.strokeJoin = StrokeJoin.round;
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
  void changeStrokeWidth({double? strokeWidth, FontWeight? fontWeight}) {
    assert((strokeWidth != null && fontWeight == null) || (strokeWidth == null && fontWeight != null));
    value = value.copyWith(
      strokeWidth: strokeWidth ?? FontWeight.values.indexOf(fontWeight!).toDouble() + 1,
    );
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

  /// Undo the previous drawing
  void undo() {
    // Ignore when paths is empty, in other words, there is no path to undo
    if (value.paths.isEmpty) {
      return;
    }

    final tmpPaths = [...value.paths];
    final tmpRemovedPaths = [...value.removedPaths, tmpPaths.removeLast()];
    value = value.copyWith(
      paths: tmpPaths,
      removedPaths: tmpRemovedPaths,
    );
    notifyListeners();
  }

  /// Redo the removed drawing
  void redo() {
    // Ignore when removedPaths is empty, in other words, there is no path to redo
    if (value.removedPaths.isEmpty) {
      return;
    }

    final tmpRemovedPaths = [...value.removedPaths];
    final tmpPaths = [...value.paths, tmpRemovedPaths.removeLast()];
    value = value.copyWith(
      paths: tmpPaths,
      removedPaths: tmpRemovedPaths,
    );
    notifyListeners();
  }

  double _initialWidth = 0;
  double _previousWidth = 0;

  /// Draw current stored paths to canvas
  void draw(Canvas canvas, Size size) async {
    double scale = 1;
    if (_previousWidth != 0) {
      print('$_previousWidth→${size.width}');
      scale = size.width / _initialWidth;
    } else {
      _initialWidth = size.width;
    }
    _previousWidth = size.width;
    // if (bgImage != null) {
    //   // Save layer with canvas size
    //   canvas.saveLayer(Offset.zero & size, Paint());

    //   // Get image aspect ratio and calculate how scaled the canvas should be by image size and canvas size
    //   final imageAspectRatio = bgImage!.width / bgImage!.height;
    //   final double scale = imageAspectRatio > 1.0 ? size.width / bgImage!.width : size.height / bgImage!.height;
    //   canvas.scale(scale);
    //   canvas.drawImage(bgImage!, Offset.zero, Paint());
    //   canvas.restore();
    // }

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.scale(scale);
    for (final element in value.paths) {
      canvas.drawPath(element.key, element.value);
    }
    canvas.restore();
  }

  Future<ui.Image> loadUiImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final list = Uint8List.view(data.buffer);
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, completer.complete);
    return completer.future;
  }

  /// Set background image from file or network image url
  void setBackgroundImage({File? file, String? imageUrl}) {
    assert((file == null && imageUrl == null) || (file != null && imageUrl == null));
    value = value.copyWith(
      paths: [],
      removedPaths: [],
      backgroundImageFile: file,
      backgroundImageUrl: imageUrl,
    );
    notifyListeners();
  }
}
