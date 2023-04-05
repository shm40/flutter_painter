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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final painterBox = painterKey.currentContext!.findRenderObject() as RenderBox;
      _painterController.onChangedOrientation(painterBox.size);
    });
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
            onPressed: () async {},
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
              child: GestureDetector(
                onPanStart: (details) {
                  final box = painterKey.currentContext!.findRenderObject() as RenderBox;
                  _painterController.add(box.globalToLocal(details.globalPosition));
                },
                onPanUpdate: (details) {
                  final box = painterKey.currentContext!.findRenderObject() as RenderBox;
                  _painterController.update(box.globalToLocal(details.globalPosition));
                },
                onPanEnd: (details) => _painterController.end(),
                child: Stack(
                  key: stackKey,
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: PainterWidget(
                        key: painterKey,
                        painterController: _painterController,
                      ),
                    ),
                    ErasingIcon(
                      painterController: _painterController,
                      painterKey: painterKey,
                      stackKey: stackKey,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
