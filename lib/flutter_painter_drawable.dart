import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'flutter_painter_drawable.freezed.dart';

@freezed
class FlutterPainterDrawable with _$FlutterPainterDrawable {
  const factory FlutterPainterDrawable({
    Path? path,
    String? iconPath,
    @Default(Offset(100, 100)) Offset iconOffset,
    @Default(1.0) double iconScale,
    @Default(0.0) double iconRotation,
    @Default(Colors.black) Color iconColor,
    DrawableRoot? iconImg,
  }) = _FlutterPainterDrawable;
}
