import 'package:flutter/material.dart';

class MyColors extends ThemeExtension<MyColors> {
  final Color containerColor;

  MyColors({required this.containerColor});

  @override
  MyColors copyWith({Color? containerColor}) {
    return MyColors(
      containerColor: containerColor ?? this.containerColor,
    );
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
    );
  }
}
