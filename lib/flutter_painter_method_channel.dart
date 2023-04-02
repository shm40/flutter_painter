import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_painter_platform_interface.dart';

/// An implementation of [FlutterPainterPlatform] that uses method channels.
class MethodChannelFlutterPainter extends FlutterPainterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_painter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
