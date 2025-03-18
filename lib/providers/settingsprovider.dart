import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ColorBlindMode { none, protanopia, deuteranopia, tritanopia, monochromacy }

final selectedMode = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
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
    state = _getThemeModeFromString(themeString);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _getStringFromThemeMode(mode));
  }

  ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
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
          (e) => e.toString().split('.').last == modeString,
      orElse: () => ColorBlindMode.none,
    );
  }

  Future<void> setColorBlindMode(ColorBlindMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('colorBlindMode', mode.toString().split('.').last);
  }
}