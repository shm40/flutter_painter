import 'dart:io';

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flutter_painter_state.freezed.dart';

@freezed
class FlutterPainterState with _$FlutterPainterState {
  const factory FlutterPainterState({
    @Default(<MapEntry<Path, MapEntry<double, Paint>>>[]) List<MapEntry<Path, MapEntry<double, Paint>>> paths,
    @Default(<MapEntry<Path, MapEntry<double, Paint>>>[]) List<MapEntry<Path, MapEntry<double, Paint>>> removedPaths,
    @Default(Offset.zero) Offset currentOffset,
    @Default(false) bool inDrag,
    @Default(false) bool eraseMode,
    @Default(Colors.black) Color lineColor,
    @Default(5.0) double strokeWidth,
    @Default(48.0) double eraseStrokeWidth,
    File? backgroundImageFile,
    String? backgroundImageUrl,
  }) = _FlutterPainterState;
}
