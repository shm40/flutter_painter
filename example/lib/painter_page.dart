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
    _painterController.setBackgroundImage(
        imageUrl:
            'https://mages.pexels.com/photos/3866555/pexels-photo-3866555.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2');
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
          IconButton(
            onPressed: () {
              if (_painterController.value.selectedIconPath == null) {
                _painterController.setIcon('asset/body_a.svg');
                return;
              }
              _painterController.addIcon();
            },
            icon: const Icon(Icons.drive_eta_rounded),
          ),
          IconButton(
            onPressed: () {
              if (_painterController.value.selectedIconPath == null) {
                _painterController.setIcon('asset/drive_eta_black_24dp.svg');
                return;
              }
              _painterController.addIcon();
            },
            icon: const Icon(Icons.drive_eta_rounded),
          ),
          ImagePickerButton(
            onSelected: (xFile) {
              _painterController.setBackgroundImage(file: File(xFile.path));
            },
            onError: (error) {
              print(error);
            },
            iconColor: Colors.black,
            cameraText: '写真を撮る',
            galleryText: 'ギャラリーから選択する',
          ),
          ShowSavedImageButton(painterController: _painterController),
          UndoButton(painterController: _painterController),
          RedoButton(painterController: _painterController),
          EraseButton(
            painterController: _painterController,
            iconColor: Colors.white,
          ),
          ColorPickerButton(painterController: _painterController),
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
              child: FlutterPainterWidget(
                painterController: _painterController,
                onReloadNetworkImage: () {
                  print('reload');
                  _painterController.setBackgroundImage(
                      imageUrl:
                          'https://images.pexels.com/photos/3866555/pexels-photo-3866555.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2');
                },
              ),
            ),
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
