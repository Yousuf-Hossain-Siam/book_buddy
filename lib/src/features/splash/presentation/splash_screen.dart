import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/presentation/onboarding_screen.dart';
import '../application/splash_navigation_notifier.dart';
import '../application/splash_notifier.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animationState = ref.watch(splashAnimationProvider);

    ref.listen<bool>(splashNavigationProvider, (previous, next) {
      if (next) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(
            offset: Offset(0, animationState.offsetY),
            child: Transform.scale(
              scale: 1.22,
              child: Image.asset(
                'assets/images/Premium Visual Element_margin.webp',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}