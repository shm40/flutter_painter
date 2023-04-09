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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ImagePickerButton(
            onSelected: (xFile) {
              _painterController.setBackgroundImage(file: File(xFile.path));
            },
          ),
          ShowSavedImageButton(painterController: _painterController),
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
            Expanded(child: FlutterPainterWidget(painterController: _painterController)),
          ],
        ),
      ),
    );
  }
}

class ShowSavedImageButton extends StatelessWidget {
  const ShowSavedImageButton({
    super.key,
    required PainterController painterController,
  }) : _painterController = painterController;

  final PainterController _painterController;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final data = await _painterController.saveCanvas<File>();

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(title: const Text('Image')),
                body: Container(
                  alignment: Alignment.center,
                  color: Colors.grey,
                  // child: Image.memory(
                  //   data.buffer.asUint8List(),
                  // ),
                  child: Image.file(data),
                ),
              );
            },
            fullscreenDialog: true,
          ),
        );
      },
      icon: const Icon(Icons.download_rounded),
    );
  }
}
