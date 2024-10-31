import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/screens/home.dart';
import 'package:abstractify/providers/settingsprovider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedValue = ref.watch(selectedMode);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      themeMode: selectedValue,
      home: const Home(),
    );
  }
}
