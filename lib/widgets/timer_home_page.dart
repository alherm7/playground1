// lib/widgets/timer_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/timer_provider.dart';
import '../providers/interval_provider.dart';

class TimerHomePage extends ConsumerWidget {
  const TimerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // reactive values
    final seconds = ref.watch(timerProvider);
    final interval = ref.watch(intervalProvider);
    final timerCtrl = ref.read(timerProvider.notifier);

    final totalCycle = interval.work.inSeconds + interval.rest.inSeconds;
    final inWork = (seconds % totalCycle) < interval.work.inSeconds;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Elapsed: $seconds s',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Text(inWork ? 'WORK' : 'REST',
                style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: timerCtrl.start, child: const Text('Start')),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: timerCtrl.stop, child: const Text('Stop')),
                const SizedBox(width: 16),
                ElevatedButton(
                    onPressed: timerCtrl.reset, child: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
