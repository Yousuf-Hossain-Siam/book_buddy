import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/counter/presentation/pages/counter_page.dart';

class BookBuddyApp extends StatelessWidget {
  const BookBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Buuuuuddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const CounterPage(),
    );
  }
}
