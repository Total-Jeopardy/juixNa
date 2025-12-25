import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme controller using Riverpod Notifier (Riverpod 3.x pattern).
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  bool get isDark => state == ThemeMode.dark;

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

/// Riverpod provider for theme controller.
final themeControllerProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
