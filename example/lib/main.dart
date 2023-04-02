import 'package:flutter/material.dart';
import 'package:flutter_painter_example/main_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  runApp(const ProviderScope(child: FlutterPainterApp()));
}

class FlutterPainterApp extends StatelessWidget {
  const FlutterPainterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Painter',
      home: MainPage(),
    );
  }
}
