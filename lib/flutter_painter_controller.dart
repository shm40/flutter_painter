import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_painter/flutter_painter_config.dart';
import 'package:flutter_painter/flutter_painter_drawable.dart';
import 'package:flutter_painter/flutter_painter_state.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PainterController extends ValueNotifier<FlutterPainterState> {
  final FlutterPainterConfig config;
  PainterController({this.config = const FlutterPainterConfig()}) : super(const FlutterPainterState());

  /// Inisital witdh of painter widget
  double _initialPainterWidth = 0;

  /// Current painter size which is initialized
  /// when painter is rendered and reinitialized when background image is set
  Size _currentPainterSize = Size.zero;

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
      paint.color = Colors.white;
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
        MapEntry(
          FlutterPainterDrawable(path: Path()..moveTo(startPosition.dx, startPosition.dy)),
          MapEntry(_currentPainterSize.width, paint),
        ),
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
    value.paths.last.key.path?.lineTo(currentPosition.dx, currentPosition.dy);

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

  /// Put icon on screen
  Future<void> setIcon(String iconPath) async {
    value = value.copyWith(selectedIconPath: iconPath);
    notifyListeners();
  }

  /// Update scale of icon
  void updateIcon({
    required double scale,
    required Offset offset,
    required double rotation,
  }) {
    value = value.copyWith(
      selectedIconScale: scale,
      selectedIconOffset: offset,
      selectedIconRotation: rotation,
    );
    notifyListeners();
  }

  /// End icon update and add path list
  Future<void> addIcon() async {
    final rawSvg = await rootBundle.loadString(value.selectedIconPath!);

    // Change icon color if the user changed current color
    final svgRoot = await svg.fromSvgString(
      rawSvg.replaceAll('#000000', '#${value.lineColor.value.toRadixString(16)}'),
      value.selectedIconPath!,
    );

    value = value.copyWith(
      paths: [
        ...value.paths,
        MapEntry(
          FlutterPainterDrawable(
            iconPath: value.selectedIconPath,
            iconOffset: value.selectedIconOffset,
            iconScale: value.selectedIconScale,
            iconRotation: value.selectedIconRotation,
            iconColor: value.lineColor,
            iconImg: svgRoot,
          ),
          MapEntry(_currentPainterSize.width, Paint()),
        ),
      ],
      selectedIconPath: null,
      selectedIconOffset: const Offset(100, 100),
      selectedIconScale: 1.0,
      selectedIconRotation: 0.0,
    );
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

  /// Set the initial canvas width when the device orientation is chagned
  void onChangedOrientation(Size painterSize) {
    final previousPainterSize = _currentPainterSize;
    _currentPainterSize = painterSize;
    if (value.selectedIconPath == null) {
      return;
    }

    // Update icon offset when the orientation chagnes
    // Basically, if the painter size is larger than before the orientation change, then offset should be larger and vice versa.
    value = value.copyWith(
      selectedIconOffset: value.selectedIconOffset * (painterSize.width / previousPainterSize.width),
    );
    notifyListeners();
  }

  /// Draw current stored paths to canvas
  void draw(Canvas canvas, Size size) async {
    if (_initialPainterWidth == 0) {
      // `_initialPainterWidth` is zero meaning that the `draw` method has just been called for the first time.
      _initialPainterWidth = size.width;
      _currentPainterSize = size;
    }

    canvas.saveLayer(Offset.zero & size, Paint());
    for (final element in value.paths) {
      if (element.key.path == null && element.key.iconPath == null) {
        continue;
      }

      // Draw line
      if (element.key.path != null) {
        canvas.save();

        // Scale the canvas to handle the device orientation change
        final scale = size.width / element.value.key;
        canvas.scale(size.width / element.value.key);

        final paint = Paint()
          ..color = element.value.value.color
          ..strokeWidth = element.value.value.strokeWidth
          ..strokeCap = element.value.value.strokeCap
          ..strokeJoin = element.value.value.strokeJoin
          ..blendMode = element.value.value.blendMode
          ..style = PaintingStyle.stroke;

        // Multiply paint stroke width by the ratio of the width which the path was drawn and the current painter width but, only when not erasing
        // This is the reciprocal of scale factor applied to canvas
        if (paint.blendMode != BlendMode.clear) {
          paint.strokeWidth = paint.strokeWidth * (1 / scale);
        }
        canvas.drawPath(element.key.path!, paint);

        canvas.restore();
        continue;
      }

      final picture = element.key.iconImg!.toPicture();
      final canvasScale = size.width / element.value.key;

      // Calculate the icon scale value because the default icon size is 24 pixel but the displayed size is 80 pixel.
      final iconScale = config.defaultIconSize * element.key.iconScale / config.defaultRawIconSize * canvasScale;

      canvas.save();

      canvas.translate(element.key.iconOffset.dx * canvasScale, element.key.iconOffset.dy * canvasScale);
      canvas.rotate(element.key.iconRotation);
      canvas.translate(-config.defaultRawIconSize * iconScale / 2, -config.defaultRawIconSize * iconScale / 2);
      canvas.scale(iconScale);
      canvas.drawPicture(picture);
      canvas.restore();
    }
    canvas.restore();
  }

  Future<ui.Image> loadUiImage({String? assetPath, String? networkImagUrl, File? imageFile}) async {
    assert((assetPath != null && networkImagUrl == null && imageFile == null) ||
        (assetPath == null && networkImagUrl != null && imageFile == null) ||
        (assetPath == null && networkImagUrl == null && imageFile != null));
    if (assetPath != null) {
      final data = await rootBundle.load(assetPath);
      final list = Uint8List.view(data.buffer);
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(list, completer.complete);
      return completer.future;
    }

    if (networkImagUrl != null) {
      final response = await http.get(Uri.parse(networkImagUrl));
      final bytes = response.bodyBytes;
      return await decodeImageFromList(bytes);
    }

    return decodeImageFromList(imageFile!.readAsBytesSync());
  }

  /// Set background image from file or network image url
  void setBackgroundImage({File? file, String? imageUrl}) {
    assert((file != null && imageUrl == null) || (file == null && imageUrl != null));

    // Reset when background image is set or reset
    _initialPainterWidth = 0;
    _currentPainterSize = Size.zero;

    value = value.copyWith(
      paths: [],
      removedPaths: [],
      backgroundImageFile: file,
      backgroundImageUrl: imageUrl,
    );
    notifyListeners();
  }

  /// Convert canvas to ByteData as png format
  ///
  /// T is return type, ByteData or File
  Future<T> saveCanvas<T>() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final double scale = ui.window.devicePixelRatio * 2;

    canvas.scale(scale);
    canvas.drawRect(Offset.zero & _currentPainterSize, Paint()..color = Colors.white);
    if (value.backgroundImageFile != null || value.backgroundImageUrl != null) {
      final uiImage = await loadUiImage(imageFile: value.backgroundImageFile, networkImagUrl: value.backgroundImageUrl);
      canvas.drawImageRect(
        uiImage,
        Offset.zero & Size(uiImage.width.toDouble(), uiImage.height.toDouble()),
        Offset.zero & _currentPainterSize,
        Paint(),
      );
    }
    draw(canvas, _currentPainterSize);

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (_currentPainterSize.width * scale).toInt(),
      (_currentPainterSize.height * scale).toInt(),
    );
    final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    if (T == ByteData) {
      return pngBytes! as T;
    }

    if (T == File) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png');
      file.writeAsBytesSync(pngBytes!.buffer.asUint8List());
      return file as T;
    }

    throw Exception('Unsupported T: $T');
  }
}
