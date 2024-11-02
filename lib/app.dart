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
    final selectedValue = ref.watch(selectedMode);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: selectedValue,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 163, 177, 138),
          brightness: Brightness.light,
        ),
        fontFamily: 'NotoSans',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 92, 78, 117),
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
