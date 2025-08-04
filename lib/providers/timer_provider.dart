/// lib/providers/timer_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits the elapsed seconds of the *current* workout.
/// ───────────────────────────────────────────────────────────
final timerProvider =
    StateNotifierProvider<TimerController, int>((ref) => TimerController());

class TimerController extends StateNotifier<int> {
  TimerController() : super(0);

  Timer? _ticker;
  static const _tick = Duration(seconds: 1);

  void start() {
    _ticker ??= Timer.periodic(_tick, (_) => state++);
  }

  void stop() {
    _ticker?.cancel();
    _ticker = null;
  }

  void reset() {
    stop();
    state = 0;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
