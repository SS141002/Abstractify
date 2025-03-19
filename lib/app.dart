import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/providers/settingsprovider.dart';
import 'package:abstractify/screens/home.dart';
import 'package:abstractify/screens/aboutus.dart';
import 'package:abstractify/screens/grammar.dart';
import 'package:abstractify/screens/handocr.dart';
import 'package:abstractify/screens/ocr.dart';
import 'package:abstractify/screens/settings.dart';
import 'package:abstractify/screens/summary.dart';
import 'package:abstractify/screens/typedocr.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  ColorScheme _getColorScheme(ColorBlindMode colorBlindMode, Brightness brightness) {
    switch (colorBlindMode) {
      case ColorBlindMode.protanopia:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF0099CC),
          primary: const Color(0xFF0099CC),
          secondary: const Color(0xFF66CC00),
          surface: brightness == Brightness.light
              ? const Color(0xFFF0F4F8)
              : const Color(0xFF2B2B2B),
          onSurface: brightness == Brightness.light
              ? const Color(0xFF2B2B2B)
              : const Color(0xFFF0F4F8),
          brightness: brightness,
        );
      case ColorBlindMode.deuteranopia:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF2671B8),
          primary: const Color(0xFF2671B8),
          secondary: const Color(0xFFD4A417),
          surface: brightness == Brightness.light
              ? const Color(0xFFE8EBEE)
              : const Color(0xFF333333),
          onSurface: brightness == Brightness.light
              ? const Color(0xFF333333)
              : const Color(0xFFE8EBEE),
          brightness: brightness,
        );
      case ColorBlindMode.tritanopia:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF7F00FF),
          primary: const Color(0xFF7F00FF),
          secondary: const Color(0xFFFF7F00),
          surface: brightness == Brightness.light
              ? const Color(0xFFF5F5F5)
              : const Color(0xFF1A1A1A),
          onSurface: brightness == Brightness.light
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFF5F5F5),
          brightness: brightness,
        );
      case ColorBlindMode.monochromacy:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF666666),
          primary: const Color(0xFF666666),
          secondary: const Color(0xFF999999),
          surface: brightness == Brightness.light
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF000000),
          onSurface: brightness == Brightness.light
              ? const Color(0xFF000000)
              : const Color(0xFFFFFFFF),
          brightness: brightness,
        );
      default:
        return ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFF6366F1),
          surface: brightness == Brightness.light
              ? const Color(0xFFFFFFFF)
              : const Color(0xFF374151),
          onSurface: brightness == Brightness.light
              ? const Color(0xFF374151)
              : const Color(0xFFD1D5DB),
          brightness: brightness,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorBlindMode = ref.watch(colorBlindModeProvider);

    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: _getColorScheme(colorBlindMode, Brightness.light),
        fontFamily: 'NotoSans',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: _getColorScheme(colorBlindMode, Brightness.dark),
        fontFamily: 'NotoSans',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/summary': (context) => Summary(),
        '/grammar': (context) => Grammar(),
        '/ocr': (context) => Ocr(),
        '/ocr/typed': (context) => TypedOcr(),
        '/ocr/hand': (context) => HandOcr(),
        '/setting': (context) => Settings(),
        '/aboutus': (context) => AboutUs(),
      },
    );
  }
}

