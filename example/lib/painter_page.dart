import 'dart:io';

import 'package:flutter_painter/widgets.dart';
import 'package:flutter_painter_example/lib.dart';

class PainterPage extends StatefulWidget {
  const PainterPage({super.key});

  @override
  State<PainterPage> createState() => _PainterPageState();
}

class _PainterPageState extends State<PainterPage> with WidgetsBindingObserver {
  late PainterController _painterController;

  @override
  void initState() {
    super.initState();
    _painterController = PainterController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _painterController.dispose();
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
    _painterController.onChangedOrientation(painterBox.size);
  }

  final painterKey = GlobalKey();
  final stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ImagePickerButton(
            onSelected: (xFile) {
              _painterController.setBackgroundImage(file: File(xFile.path));
            },
          ),
          IconButton(
            onPressed: () async {
              final data = await _painterController.saveCanvasAsPngImage();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return Scaffold(
                      backgroundColor: Colors.white,
                      appBar: AppBar(title: const Text('Image')),
                      body: Container(
                        alignment: Alignment.center,
                        color: Colors.grey,
                        child: Image.memory(
                          data.buffer.asUint8List(),
                        ),
                      ),
                    );
                  },
                  fullscreenDialog: true,
                ),
              );
            },
            icon: const Icon(Icons.download_rounded),
          ),
          UndoButton(painterController: _painterController),
          RedoButton(painterController: _painterController),
          EraseButton(painterController: _painterController),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.grey.shade100,
              height: 80,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  LineColorSelector(painterController: _painterController),
                  StrokeWidthSettingButton(painterController: _painterController),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                key: stackKey,
                children: [
                  GestureDetector(
                    onPanStart: (details) {
                      final box = painterKey.currentContext!.findRenderObject() as RenderBox;
                      _painterController.add(box.globalToLocal(details.globalPosition));
                    },
                    onPanUpdate: (details) {
                      final box = painterKey.currentContext!.findRenderObject() as RenderBox;
                      _painterController.update(box.globalToLocal(details.globalPosition));
                    },
                    onPanEnd: (details) => _painterController.end(),
                    child: Center(
                      child: PainterWidget(
                        key: painterKey,
                        painterController: _painterController,
                        aspectRatio: 3 / 1.2,
                      ),
                    ),
                  ),
                  // SelectedIcon(
                  //   painterController: _painterController,
                  //   painterKey: painterKey,
                  //   stackKey: stackKey,
                  //   icon: Icons.drive_eta_rounded,
                  // ),
                  ErasingIcon(
                    painterController: _painterController,
                    painterKey: painterKey,
                    stackKey: stackKey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
