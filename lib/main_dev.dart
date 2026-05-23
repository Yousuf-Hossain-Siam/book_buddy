import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Environment: dev
  runApp(ProviderScope(overrides: [
    configProvider.overrideWithValue(const Config(baseUrl: 'https://api.dev.bookbuddy.example'))
  ], child: const BookBuddyApp()));
}
