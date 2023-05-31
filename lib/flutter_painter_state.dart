import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_painter/flutter_painter_drawable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flutter_painter_state.freezed.dart';

@freezed
class FlutterPainterState with _$FlutterPainterState {
  const factory FlutterPainterState({
    @Default(<MapEntry<FlutterPainterDrawable, MapEntry<double, Paint>>>[])
        List<MapEntry<FlutterPainterDrawable, MapEntry<double, Paint>>> paths,
    @Default(<MapEntry<FlutterPainterDrawable, MapEntry<double, Paint>>>[])
        List<MapEntry<FlutterPainterDrawable, MapEntry<double, Paint>>> removedPaths,
    @Default(Offset.zero) Offset currentOffset,
    @Default(false) bool inDrag,
    @Default(false) bool eraseMode,
    @Default(Colors.black) Color lineColor,
    @Default(5.0) double strokeWidth,
    @Default(48.0) double eraseStrokeWidth,
    File? backgroundImageFile,
    String? backgroundImageUrl,
    String? selectedIconPath,
    @Default(1.0) double selectedIconScale,
    @Default(0.0) double selectedIconRotation,
    @Default(Offset(100, 100)) Offset selectedIconOffset,
    @Default(false) bool disablePainting,
  }) = _FlutterPainterState;
}
