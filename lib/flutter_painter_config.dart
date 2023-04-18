class FlutterPainterConfig {
  /// Default canvas aspect ratio
  ///
  /// When the background image is set, this is ignored
  final double defaultAspectRatio;

  /// Default erase stroke width
  final double defaultEraseStrokeWidth;

  /// Default icon size
  final double defaultIconSize;

  const FlutterPainterConfig({
    this.defaultAspectRatio = 210 / 297, // Default A4 size
    this.defaultEraseStrokeWidth = 48.0,
    this.defaultIconSize = 80,
  });
}
