import 'package:flutter_painter_example/lib.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late FlutterPainterController _painterController;

  @override
  void initState() {
    super.initState();
    _painterController = FlutterPainterController();
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
            onPressed: () {
              ref.watch(eraseModeProvider.notifier).changeEraseMode();
              _painterController.changeEraseMode();
            },
            icon: Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? child) {
                final eraseMode = ref.watch(eraseModeProvider);
                return Icon(
                  FontAwesomeIcons.eraser,
                  color: Colors.white.withOpacity(eraseMode ? 1.0 : 0.38),
                );
              },
            ),
          )
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (details) {
                _painterController.add(details.localPosition);
                ref.watch(erasePositionProvider.notifier).updatePosition(details.localPosition);
              },
              onPanUpdate: (details) {
                _painterController.update(details.localPosition);
                ref.watch(erasePositionProvider.notifier).updatePosition(details.localPosition);
              },
              onPanEnd: (details) {
                _painterController.end();
                ref.watch(erasePositionProvider.notifier).updatePosition(Offset.zero);
              },
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
                  Consumer(
                    builder: (context, ref, child) {
                      // eraseModeではないもしくはerasePositionがOffset.zeroのときはアイコン非表示
                      if (!ref.watch(eraseModeProvider)) {
                        return const SizedBox.shrink();
                      }

                      if (ref.watch(erasePositionProvider) == Offset.zero) {
                        return const SizedBox.shrink();
                      }
                      return Positioned.fromRect(
                        rect: Rect.fromCenter(center: ref.watch(erasePositionProvider), width: 48, height: 48),
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
