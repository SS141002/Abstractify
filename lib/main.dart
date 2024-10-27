import 'dart:io';
import 'package:flutter/material.dart';
import 'package:abstractify/home.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:serious_python/serious_python.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(1280, 720));
    WindowManager.instance.setAspectRatio(16 / 9);
  }

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(256, 163, 177, 138),
            brightness: Brightness.light),
        fontFamily: 'NotoSans',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 90, 64),
            brightness: Brightness.dark),
        fontFamily: 'NotoSans',
      ),
      themeMode: ThemeMode.system,
      home: const Home(),
    ),
  );
}
