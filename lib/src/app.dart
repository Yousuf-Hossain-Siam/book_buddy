import 'package:book_buddy_/src/features/splash/presentation/splash_screen.dart';

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';


class BookBuddyApp extends StatelessWidget {
  const BookBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Buddy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
