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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(selectedMode);

    return MaterialApp(
      restorationScopeId: 'app',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Blue-500
          primary: const Color(0xFF3B82F6), // Blue-500
          secondary: const Color(0xFF6366F1), // Indigo-500
          surface: const Color(0xFFFFFFFF), // White
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFF374151), // Gray-700
          brightness: Brightness.light,
        ),
        fontFamily: 'NotoSans',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Blue-500
          primary: const Color(0xFF3B82F6), // Blue-500
          secondary: const Color(0xFF6366F1), // Indigo-500
          surface: const Color(0xFF374151), // Gray-700
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xFFD1D5DB), // Gray-300
          brightness: Brightness.dark,
        ),
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
