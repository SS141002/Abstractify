import 'package:abstractify/screens/navdrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abstractify/providers/settingsprovider.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(selectedMode);
    final colorBlindMode = ref.watch(colorBlindModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: const [BackButton()],
      ),
      drawer: const NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeSelector(themeMode),
            const SizedBox(height: 30),
            _buildColorBlindSelector(colorBlindMode),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeMode themeMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("App Theme", style: TextStyle(fontSize: 18)),
        SizedBox(
          width: 200,
          child: DropdownButton<ThemeMode>(
            value: themeMode,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text("System Default"),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text("Light Theme"),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text("Dark Theme"),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                ref.read(selectedMode.notifier).setTheme(mode);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorBlindSelector(ColorBlindMode currentMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Color Accessibility", style: TextStyle(fontSize: 18)),
        SizedBox(
          width: 200,
          child: DropdownButton<ColorBlindMode>(
            value: currentMode,
            isExpanded: true,
            items: const [
              DropdownMenuItem(
                value: ColorBlindMode.none,
                child: Text("None"),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.protanopia,
                child: Text("Protanopia"),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.deuteranopia,
                child: Text("Deuteranopia"),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.tritanopia,
                child: Text("Tritanopia"),
              ),
              DropdownMenuItem(
                value: ColorBlindMode.monochromacy,
                child: Text("Monochromacy"),
              ),
            ],
            onChanged: (mode) {
              if (mode != null) {
                ref.read(colorBlindModeProvider.notifier).setColorBlindMode(mode);
              }
            },
          ),
        ),
      ],
    );
  }
}