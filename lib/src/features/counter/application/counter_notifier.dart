import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/counter_state.dart';

final counterNotifierProvider =
    NotifierProvider<CounterNotifier, CounterState>(CounterNotifier.new);

class CounterNotifier extends Notifier<CounterState> {
  @override
  CounterState build() {
    return const CounterState(count: 0);
  }

  void increment() {
    state = state.copyWith(count: state.count + 1);
  }

  void decrement() {
    state = state.copyWith(count: state.count - 1);
  }

  void reset() {
    state = state.copyWith(count: 0);
  }
}
