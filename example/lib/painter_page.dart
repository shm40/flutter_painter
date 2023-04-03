import 'package:flutter_painter/flutter_painter_state.dart';
import 'package:flutter_painter_example/lib.dart';

class PainterPage extends StatefulWidget {
  const PainterPage({super.key});

  @override
  State<PainterPage> createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> {
  late PainterController _painterController;

  @override
  void initState() {
    super.initState();
    _painterController = PainterController();
  }

  @override
  void dispose() {
    _painterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Painter'),
        actions: [
          IconButton(
            onPressed: _painterController.toggleEraseMode,
            icon: ValueListenableBuilder<FlutterPainterState>(
              builder: (context, value, child) {
                return Icon(
                  FontAwesomeIcons.eraser,
                  color: Colors.white.withOpacity(value.eraseMode ? 1.0 : 0.38),
                );
              },
              valueListenable: _painterController,
            ),
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) => _painterController.add(details.localPosition),
              onPanUpdate: (details) => _painterController.update(details.localPosition),
              onPanEnd: (details) => _painterController.end(),
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CustomPaint(
                      painter: FlutterPainter(_painterController, repaint: _painterController),
                      willChange: true,
                    ),
                  ),
                  ValueListenableBuilder<FlutterPainterState>(
                    valueListenable: _painterController,
                    builder: (context, value, child) {
                      // eraseModeではないもしくはerasePositionがOffset.zeroのときはアイコン非表示
                      if (!(value.eraseMode && value.inDrag)) {
                        return const SizedBox.shrink();
                      }

                      return Positioned.fromRect(
                        rect: Rect.fromCenter(
                          center: value.currentOffset,
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
