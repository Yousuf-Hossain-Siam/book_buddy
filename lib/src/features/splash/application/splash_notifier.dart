import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashAnimationState {
  const SplashAnimationState({
    required this.offsetY,
    required this.movingUp,
  });

  final double offsetY;
  final bool movingUp;

  SplashAnimationState copyWith({
    double? offsetY,
    bool? movingUp,
  }) {
    return SplashAnimationState(
      offsetY: offsetY ?? this.offsetY,
      movingUp: movingUp ?? this.movingUp,
    );
  }
}

class SplashAnimationNotifier extends StateNotifier<SplashAnimationState> {
  SplashAnimationNotifier()
      : super(const SplashAnimationState(offsetY: 10, movingUp: true)) {
    _timer = Timer.periodic(const Duration(milliseconds: 24), _tick);
  }

  static const double _minOffset = -10;
  static const double _maxOffset = 10;
  static const double _step = 0.4;

  Timer? _timer;

  void _tick(Timer timer) {
    final nextOffset = state.offsetY + (state.movingUp ? -_step : _step);

    if (nextOffset <= _minOffset) {
      state = state.copyWith(offsetY: _minOffset, movingUp: false);
      return;
    }

    if (nextOffset >= _maxOffset) {
      state = state.copyWith(offsetY: _maxOffset, movingUp: true);
      return;
    }

    state = state.copyWith(offsetY: nextOffset);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final splashAnimationProvider =
    StateNotifierProvider<SplashAnimationNotifier, SplashAnimationState>(
  (ref) => SplashAnimationNotifier(),
);
