import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Environment: prod
  runApp(ProviderScope(overrides: [
    configProvider.overrideWithValue(const Config(baseUrl: 'https://api.bookbuddy.example'))
  ], child: const BookBuddyApp()));
}
