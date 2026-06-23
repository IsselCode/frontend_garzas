import 'package:flutter/material.dart';

TextStyle? scaledTextStyle(
  TextStyle? baseStyle,
  double scaleFactor, {
  Color? color,
  FontWeight? fontWeight,
}) {
  if (baseStyle == null) return null;

  return baseStyle.copyWith(
    fontSize: (baseStyle.fontSize ?? 14) * scaleFactor,
    color: color,
    fontWeight: fontWeight,
  );
}
