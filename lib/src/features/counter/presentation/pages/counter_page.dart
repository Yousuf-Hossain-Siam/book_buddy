import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/counter_notifier.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterNotifierProvider);
    final counterNotifier = ref.read(counterNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Riverpod Architecture')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Count', style: TextStyle(fontSize: 16)),
            Text(
              '${counterState.count}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  onPressed: counterNotifier.decrement,
                  child: const Text('-'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: counterNotifier.increment,
                  child: const Text('+'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: counterNotifier.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
