import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:abstractify/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.setMinimumSize(const Size(1200, 830));
    await windowManager.setSize(Size(1200, 830));  // Set initial size
    await windowManager.setAspectRatio(1200 / 830);
  }

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
