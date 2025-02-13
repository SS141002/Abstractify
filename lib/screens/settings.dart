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
    var themeMode = ref.watch(selectedMode);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        actions: [
          BackButton(),
        ],
      ),
      drawer: NavDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 100),
                Text(
                  "App Theme",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 100),
                SizedBox(
                  width: 160,
                  child: DropdownButton<ThemeMode>(
                    value: themeMode,
                    isExpanded: true,
                    icon: themeMode == ThemeMode.light
                        ? Icon(Icons.light_mode)
                        : Icon(Icons.dark_mode),
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("System Default"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Light Theme"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Text("Dark Theme"),
                        ),
                      ),
                    ],
                    onChanged: (ThemeMode? newMode) {
                      if (newMode != null) {
                        ref.read(selectedMode.notifier).setTheme(newMode);
                        setState(() {
                          themeMode = newMode;
                        });
                      }
                    },
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
