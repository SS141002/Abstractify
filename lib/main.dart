import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:abstractify/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows) {
    WindowManager.instance.setMinimumSize(const Size(1280, 720));
    WindowManager.instance.setAspectRatio(16 / 9);
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
