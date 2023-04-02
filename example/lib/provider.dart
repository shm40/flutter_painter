import 'package:flutter_painter_example/lib.dart';

final eraseModeProvider = StateNotifierProvider<EraseModeController, bool>((ref) {
  return EraseModeController();
});

class EraseModeController extends StateNotifier<bool> {
  EraseModeController() : super(false);

  void changeEraseMode() {
    state = !state;
  }
}

final erasePositionProvider = StateNotifierProvider<ErasePositionController, Offset>((ref) {
  return ErasePositionController();
});

class ErasePositionController extends StateNotifier<Offset> {
  ErasePositionController() : super(Offset.zero);

  void updatePosition(Offset position) {
    state = position;
  }
}
