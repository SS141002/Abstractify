import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorBlindMode { none, protanopia, deuteranopia, tritanopia, monochromacy }

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final colorBlindModeProvider = StateNotifierProvider<ColorBlindNotifier, ColorBlindMode>((ref) {
  return ColorBlindNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'system';
    state = ThemeMode.values.firstWhere(
          (e) => e.name == themeString,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }
}

class ColorBlindNotifier extends StateNotifier<ColorBlindMode> {
  ColorBlindNotifier() : super(ColorBlindMode.none) {
    _loadColorBlindMode();
  }

  Future<void> _loadColorBlindMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString('colorBlindMode') ?? 'none';
    state = ColorBlindMode.values.firstWhere(
          (e) => e.name == modeString,
      orElse: () => ColorBlindMode.none,
    );
  }

  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorBlindMode', mode.name);
  }
}
