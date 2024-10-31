import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMode = StateProvider<ThemeMode>((ref) => ThemeMode.system);
