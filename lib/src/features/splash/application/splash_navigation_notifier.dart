import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashNavigationNotifier extends StateNotifier<bool> {
  SplashNavigationNotifier() : super(false) {
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        state = true;
      }
    });
  }

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final splashNavigationProvider =
    StateNotifierProvider<SplashNavigationNotifier, bool>(
  (ref) => SplashNavigationNotifier(),
);