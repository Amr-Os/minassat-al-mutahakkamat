// Monochrome (grayscale-only) palette. Status is conveyed by shape and
// text (RUNNING vs STOPPED), never by hue. The only pure-white surface is
// the QR code itself, which must stay black-on-white to remain scannable.

import 'package:flutter/material.dart';

class Mono {
  static const bg = Color(0xFF0E0E0E);
  static const sideBg = Color(0xFF141414);
  static const cardBg = Color(0xFF151515);
  static const inputBg = Color(0xFF101010);
  static const selectedBg = Color(0xFF242424);
  static const border = Color(0xFF262626);
  static const borderStrong = Color(0xFF3A3A3A);
  static const text = Color(0xFFD6D6D6);
  static const bright = Color(0xFFF5F5F5);
  static const muted = Color(0xFFA3A3A3);
  static const faint = Color(0xFF6E6E6E);
  static const pressed = Color(0xFF2E2E2E);
}

ThemeData monoTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: Mono.bg,
    colorScheme: const ColorScheme.dark(
      primary: Mono.bright,
      surface: Mono.cardBg,
      onSurface: Mono.text,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Mono.text,
      displayColor: Mono.bright,
    ),
  );
}
