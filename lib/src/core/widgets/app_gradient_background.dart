import 'package:flutter/material.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child});

  final Widget child;

  static const LinearGradient gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F7E9),
      Color(0xFFF1FAF0),
      Color(0xFFEAF7F8),
      Color(0xFFEAF4FF),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}