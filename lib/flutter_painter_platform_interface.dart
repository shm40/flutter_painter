import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_painter_method_channel.dart';

abstract class FlutterPainterPlatform extends PlatformInterface {
  /// Constructs a FlutterPainterPlatform.
  FlutterPainterPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterPainterPlatform _instance = MethodChannelFlutterPainter();

  /// The default instance of [FlutterPainterPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterPainter].
  static FlutterPainterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterPainterPlatform] when
  /// they register themselves.
  static set instance(FlutterPainterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
