import 'package:flutter/material.dart';
import 'package:flutter_painter_example/painter_page.dart';

Future<void> main() async {
  runApp(const FlutterPainterApp());
}

class FlutterPainterApp extends StatelessWidget {
  const FlutterPainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Painter',
      home: PainterPage(),
    );
  }
}
