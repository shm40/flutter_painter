import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_painter/flutter_painter_config.dart';
import 'package:flutter_painter/flutter_painter_controller.dart';
import 'package:flutter_painter/flutter_painter_state.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

const colors = [
  Colors.black,
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.yellow,
];

/// Setting button to change stroke width by selecting fontWeight which is converted to strokeWidth in double type
class StrokeWidthSettingButton extends StatelessWidget {
  const StrokeWidthSettingButton({
    super.key,
    required this.painterController,
  });

  final PainterController painterController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: painterController,
      builder: (context, value, child) {
        final strokeWidth = value.strokeWidth;
        final fontWeight =
            strokeWidth < 0 || strokeWidth > 9 ? FontWeight.normal : FontWeight.values[value.strokeWidth.toInt() - 1];
        return PopupMenuButton<FontWeight>(
          onSelected: (value) => painterController.changeStrokeWidth(fontWeight: value),
          icon: Text(
            'A',
            style: TextStyle(fontWeight: fontWeight, fontSize: 24),
          ),
          itemBuilder: (context) {
            return FontWeight.values
                .map((e) => PopupMenuItem(
                    value: e,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'A',
                            style: TextStyle(fontWeight: e),
                            selectionColor: Colors.orange,
                          ),
                        ),
                        Visibility(
                          visible: fontWeight == e,
                          child: const Icon(Icons.check_rounded),
                        ),
                      ],
                    )))
                .toList();
          },
        );
      },
    );
  }
}

/// Color selector to change the color of lines when drawing
class LineColorSelector extends StatelessWidget {
  const LineColorSelector({
    super.key,
    required this.painterController,
    this.childSize = 40,
  });

  final PainterController painterController;
  final double childSize;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FlutterPainterState>(
      builder: (context, value, child) {
        return ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final color = colors[index];
            return GestureDetector(
              onTap: () => painterController.changeLineColor(color),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(childSize / 2),
                  ),
                  height: childSize,
                  width: childSize,
                  child: value.lineColor == color ? const Icon(Icons.check_rounded, color: Colors.white) : null,
                ),
              ),
            );
          },
          itemCount: colors.length,
        );
      },
      valueListenable: painterController,
    );
  }
}

/// Erase button to erase the drew lines
class EraseButton extends StatelessWidget {
  const EraseButton({
    super.key,
    required this.painterController,
    this.iconColor = Colors.white,
    this.size = 40,
  });

  final PainterController painterController;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FlutterPainterState>(
      builder: (context, value, child) {
        return GestureDetector(
          onTap: painterController.toggleEraseMode,
          child: Container(
            width: size,
            height: size,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: value.eraseMode ? iconColor : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(size / 2),
            ),
            child: Icon(
              FontAwesomeIcons.eraser,
              color: iconColor,
            ),
          ),
        );
      },
      valueListenable: painterController,
    );
  }
}

/// Button to redo the previous removed lines
class RedoButton extends StatelessWidget {
  const RedoButton({
    super.key,
    required this.painterController,
  });

  final PainterController painterController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FlutterPainterState>(
      valueListenable: painterController,
      builder: (context, value, child) {
        return IconButton(
          onPressed: value.removedPaths.isEmpty ? null : painterController.redo,
          icon: const Icon(Icons.redo_rounded),
        );
      },
    );
  }
}

/// Button to undo the current drew line
class UndoButton extends StatelessWidget {
  const UndoButton({
    super.key,
    required this.painterController,
  });

  final PainterController painterController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: painterController,
      builder: (context, value, child) {
        return IconButton(
          onPressed: value.paths.isEmpty ? null : painterController.undo,
          icon: const Icon(Icons.undo_rounded),
        );
      },
    );
  }
}

/// Drawable widget that incorporating painter widget and erasing icon
class FlutterPainterWidget extends StatefulWidget {
  const FlutterPainterWidget({super.key, required this.painterController, this.config = const FlutterPainterConfig()});
  final PainterController painterController;
  final FlutterPainterConfig config;

  @override
  State<FlutterPainterWidget> createState() => _FlutterPainterWidgetState();
}

class _FlutterPainterWidgetState extends State<FlutterPainterWidget> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculatePainterSize();
    });
  }

  void _calculatePainterSize() {
    final painterBox = painterKey.currentContext!.findRenderObject() as RenderBox;
    widget.painterController.onChangedOrientation(painterBox.size);
  }

  final painterKey = GlobalKey();
  final stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: stackKey,
      children: [
        GestureDetector(
          onPanStart: (details) {
            final box = painterKey.currentContext!.findRenderObject() as RenderBox;
            widget.painterController.add(box.globalToLocal(details.globalPosition));
          },
          onPanUpdate: (details) {
            final box = painterKey.currentContext!.findRenderObject() as RenderBox;
            widget.painterController.update(box.globalToLocal(details.globalPosition));
          },
          onPanEnd: (details) => widget.painterController.end(),
          child: Center(
            child: SimplePainterWidget(
              key: painterKey,
              painterController: widget.painterController,
              aspectRatio: widget.config.aspectRatio,
            ),
          ),
        ),
        ErasingIcon(
          painterController: widget.painterController,
          painterKey: painterKey,
          stackKey: stackKey,
        ),
      ],
    );
  }
}

/// Custom paint widget
class SimplePainterWidget extends StatelessWidget {
  const SimplePainterWidget({
    super.key,
    required this.painterController,
    required this.aspectRatio,
  });

  final PainterController painterController;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: painterController,
      builder: (context, value, child) {
        final isBackgroundEmpty = value.backgroundImageFile == null && value.backgroundImageUrl == null;
        final child = isBackgroundEmpty
            ? const SizedBox(width: double.infinity, height: double.infinity)
            : value.backgroundImageFile != null
                ? Image.file(value.backgroundImageFile!)
                : Image.network(value.backgroundImageUrl!);
        if (isBackgroundEmpty) {
          return AspectRatio(
            aspectRatio: aspectRatio,
            child: CustomPaint(
              foregroundPainter: FlutterPainter(painterController, repaint: painterController),
              willChange: true,
              child: Container(color: Colors.white),
            ),
          );
        }
        return CustomPaint(
          foregroundPainter: FlutterPainter(painterController, repaint: painterController),
          willChange: true,
          child: child,
        );
      },
    );
  }
}

/// Erase icon which is displayed in erasing mode and erasing by touch
class ErasingIcon extends StatelessWidget {
  const ErasingIcon({
    super.key,
    required this.painterController,
    required this.painterKey,
    required this.stackKey,
  });

  final PainterController painterController;
  final GlobalKey painterKey;
  final GlobalKey stackKey;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FlutterPainterState>(
      valueListenable: painterController,
      builder: (context, value, child) {
        // eraseModeではないもしくはerasePositionがOffset.zeroのときはアイコン非表示
        if (!(value.eraseMode && value.inDrag)) {
          return const SizedBox.shrink();
        }

        // Painter offset from parent stack widget
        final parentBox = stackKey.currentContext!.findRenderObject() as RenderBox;
        final parentGlobalOffset = parentBox.localToGlobal(Offset.zero);

        // Painter box
        final painterBox = painterKey.currentContext!.findRenderObject() as RenderBox;
        final painterGlobalOffset = painterBox.localToGlobal(Offset.zero);

        return Positioned.fromRect(
          rect: Rect.fromCenter(
            center: value.currentOffset + (painterGlobalOffset - parentGlobalOffset),
            width: value.eraseStrokeWidth,
            height: value.eraseStrokeWidth,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}

/// Selected icon which can be dragglable until fixed
class SelectedIcon extends StatefulWidget {
  const SelectedIcon({
    super.key,
    required this.painterController,
    required this.painterKey,
    required this.stackKey,
    required this.icon,
  });

  final PainterController painterController;
  final GlobalKey painterKey;
  final GlobalKey stackKey;
  final IconData icon;

  @override
  State<SelectedIcon> createState() => _SelectedIconState();
}

class _SelectedIconState extends State<SelectedIcon> with WidgetsBindingObserver {
  Offset _offset = const Offset(100, 100);
  Offset _dragStartOffset = Offset.zero;
  double _scale = 1;
  Offset parentGlobalOffset = Offset.zero;
  Offset painterGlobalOffset = Offset.zero;
  Offset diffOffsetInPainterAndStack = Offset.zero;

  Offset _scalerDragStartOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _calculateOffset();
      });
    });
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    setState(() {
      _calculateOffset();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _calculateOffset() {
    // Painter offset from parent stack widget
    final parentBox = widget.stackKey.currentContext!.findRenderObject() as RenderBox;
    parentGlobalOffset = parentBox.localToGlobal(Offset.zero);

    // Painter box
    final painterBox = widget.painterKey.currentContext!.findRenderObject() as RenderBox;
    painterGlobalOffset = painterBox.localToGlobal(Offset.zero);

    diffOffsetInPainterAndStack = painterGlobalOffset - parentGlobalOffset;
    _offset += diffOffsetInPainterAndStack;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fromRect(
          rect: Rect.fromCenter(center: _offset, width: 72 * _scale, height: 72 * _scale),
          child: GestureDetector(
            onScaleStart: (details) {
              final stackBox = widget.stackKey.currentContext!.findRenderObject() as RenderBox;
              _dragStartOffset = stackBox.globalToLocal(details.focalPoint) - _offset;
            },
            onScaleUpdate: (details) {
              final stackBox = widget.stackKey.currentContext!.findRenderObject() as RenderBox;
              setState(() {
                _offset = stackBox.globalToLocal(details.focalPoint) - _dragStartOffset;
              });
            },
            onScaleEnd: (details) {
              _dragStartOffset = Offset.zero;
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blue,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Icon(
                widget.icon,
                size: 72 * _scale,
              ),
            ),
          ),
        ),
        Positioned.fromRect(
          rect:
              Rect.fromCenter(center: (_offset + Offset((72 * _scale) / 2, (72 * _scale) / 2)), width: 24, height: 24),
          child: GestureDetector(
            onScaleStart: (details) {
              final stackBox = widget.stackKey.currentContext!.findRenderObject() as RenderBox;
              _scalerDragStartOffset = stackBox.globalToLocal(details.focalPoint);
            },
            onScaleUpdate: (details) {
              final stackBox = widget.stackKey.currentContext!.findRenderObject() as RenderBox;
              final currentOffset = stackBox.globalToLocal(details.focalPoint);
              setState(() {
                _scale = (36 + (currentOffset.dx - _scalerDragStartOffset.dx)) / 36;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Button to select image by taking a photo or from gallery
class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({super.key, required this.onSelected});
  final ValueChanged<XFile> onSelected;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final ImageSource? imageSource = await showModalBottomSheet(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          context: context,
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                    leading: const Icon(Icons.camera_alt_rounded),
                    title: const Text('写真を撮る'),
                  ),
                  ListTile(
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                    leading: const Icon(Icons.image_rounded),
                    title: const Text('ギャラリーから選択する'),
                  ),
                ],
              ),
            );
          },
        );
        if (imageSource == null) {
          return;
        }
        final xFile = await ImagePicker().pickImage(source: imageSource);
        if (xFile == null) {
          return;
        }
        onSelected(xFile);
      },
      icon: const Icon(Icons.image_rounded),
    );
  }
}

/// Color picker button
class ColorPickerButton extends StatelessWidget {
  const ColorPickerButton({super.key, required this.painterController});
  final PainterController painterController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FlutterPainterState>(
      valueListenable: painterController,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                titlePadding: const EdgeInsets.all(0.0),
                contentPadding: const EdgeInsets.all(0.0),
                content: SingleChildScrollView(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ColorPicker(
                      pickerColor: value.lineColor,
                      onColorChanged: painterController.changeLineColor,
                      colorPickerWidth: 300.0,
                      pickerAreaHeightPercent: 0.7,
                      enableAlpha: true,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsv,
                    ),
                  ),
                ),
              ),
            );
          },
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: value.lineColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}
