// providers/timer_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/tts_service.dart';

enum SessionState { idle, running, paused, finished }

class TimerSession {
  final WorkoutPlan plan;
  final int roundIndex; // 0-based
  final int exerciseIndex; // 0-based (points to *next* exercise during rests)
  final bool isRest;
  final int secondsLeft;
  final int totalElapsed; // seconds across whole session
  final SessionState state;

  const TimerSession({
    required this.plan,
    required this.roundIndex,
    required this.exerciseIndex,
    required this.isRest,
    required this.secondsLeft,
    required this.totalElapsed,
    required this.state,
  });

  String get currentLabel => isRest
      ? (secondsLeft > 0 ? 'Rest' : 'Transition')
      : plan.exercises[exerciseIndex].name;

  TimerSession copyWith({
    WorkoutPlan? plan,
    int? roundIndex,
    int? exerciseIndex,
    bool? isRest,
    int? secondsLeft,
    int? totalElapsed,
    SessionState? state,
  }) {
    return TimerSession(
      plan: plan ?? this.plan,
      roundIndex: roundIndex ?? this.roundIndex,
      exerciseIndex: exerciseIndex ?? this.exerciseIndex,
      isRest: isRest ?? this.isRest,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      totalElapsed: totalElapsed ?? this.totalElapsed,
      state: state ?? this.state,
    );
  }
}

final ttsProvider = Provider<TtsService>((_) => TtsService());
final voiceEnabledProvider = StateProvider<bool>((_) => true);
final currentPlanProvider = StateProvider<WorkoutPlan?>((_) => null);

final timerProvider = StateNotifierProvider<TimerController, TimerSession?>(
  (ref) => TimerController(ref),
);

class TimerController extends StateNotifier<TimerSession?> {
  final Ref ref;
  Timer? _ticker;

  TimerController(this.ref) : super(null);

  void start(WorkoutPlan plan) {
    _ticker?.cancel();
    final first = plan.exercises.first;
    state = TimerSession(
      plan: plan,
      roundIndex: 0,
      exerciseIndex: 0,
      isRest: false,
      secondsLeft: first.seconds,
      totalElapsed: 0,
      state: SessionState.running,
    );
    _announce('Starting ${plan.name}. '
        'Round 1 of ${plan.rounds}. First: ${first.name}.');
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (state == null) return;
    _ticker?.cancel();
    state = state!.copyWith(state: SessionState.paused);
  }

  void resume() {
    if (state == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    state = state!.copyWith(state: SessionState.running);
  }

  void stop() {
    _ticker?.cancel();
    state = null;
  }

  /// Skip the current segment (exercise or rest) and immediately advance to
  /// what comes next in the plan.
  void skip() {
    final s = state;
    if (s == null) return;
    // Set the remaining time to zero and use the same advancing logic that
    // happens at natural boundaries.
    state = s.copyWith(secondsLeft: 0);
    _advanceImmediate();
  }

  void _tick() {
    final s = state;
    if (s == null || s.state != SessionState.running) return;

    if (s.secondsLeft <= 1) {
      // Consume the last second of the current segment.
      final consumed = s.copyWith(
        totalElapsed: s.totalElapsed + 1,
        secondsLeft: 0,
      );
      state = consumed;
      _advanceImmediate(); // can fast-forward through 0s instantly
    } else {
      final next = s.copyWith(
        secondsLeft: s.secondsLeft - 1,
        totalElapsed: s.totalElapsed + 1,
      );
      state = next;
      if (next.secondsLeft <= 3 && next.secondsLeft >= 1) {
        _announce('${next.secondsLeft}');
      }
    }
  }

  /// Move to the next logical segment, *fast-forwarding through any 0-second*
  /// rests/segments so there is no artificial 1s delay.
  void _advanceImmediate() {
    var s = state!;
    final plan = s.plan;

    while (true) {
      if (s.state == SessionState.finished) break;

      if (!s.isRest) {
        // Finished an exercise
        final isLastExercise = s.exerciseIndex == plan.exercises.length - 1;

        if (!isLastExercise) {
          // Between exercises
          final nextExerciseIndex = s.exerciseIndex + 1;
          final rest = plan.restBetweenExercises;

          if (rest > 0) {
            s = s.copyWith(
              isRest: true,
              secondsLeft: rest,
              exerciseIndex: nextExerciseIndex, // point to upcoming
            );
            state = s;
            _announce('Rest $rest seconds. '
                'Next: ${plan.exercises[nextExerciseIndex].name}.');
            break; // non-zero rest → wait for ticks
          } else {
            // Instant transition to next exercise
            s = s.copyWith(
              isRest: false,
              exerciseIndex: nextExerciseIndex,
              secondsLeft: plan.exercises[nextExerciseIndex].seconds,
            );
            state = s;
            _announce('Go: ${plan.exercises[nextExerciseIndex].name}!');
            if (s.secondsLeft > 0) break; // if zero (weird), loop again
            continue;
          }
        } else {
          // Finished last exercise of the round
          final isLastRound = s.roundIndex == plan.rounds - 1;

          if (!isLastRound) {
            final nextRound = s.roundIndex + 1;
            final roundRest = plan.restBetweenRounds;

            if (roundRest > 0) {
              s = s.copyWith(
                isRest: true,
                secondsLeft: roundRest,
                roundIndex: nextRound,
                exerciseIndex: 0,
              );
              state = s;
              _announce(
                  'Round $nextRound starts after $roundRest seconds of rest.');
              break;
            } else {
              // Instant jump to next round's first exercise
              s = s.copyWith(
                isRest: false,
                roundIndex: nextRound,
                exerciseIndex: 0,
                secondsLeft: plan.exercises.first.seconds,
              );
              state = s;
              _announce('Round $nextRound. Go: ${plan.exercises.first.name}!');
              if (s.secondsLeft > 0) break;
              continue;
            }
          } else {
            // Finished entire workout
            _ticker?.cancel();
            s = s.copyWith(state: SessionState.finished);
            state = s;
            _announce('Workout complete. Awesome job!');
            break;
          }
        }
      } else {
        // Coming out of a rest → start the designated exercise
        final ex = s.plan.exercises[s.exerciseIndex];
        s = s.copyWith(isRest: false, secondsLeft: ex.seconds);
        state = s;
        _announce('Go: ${ex.name}!');
        if (s.secondsLeft > 0) break; // zero-length exercise (edge) → loop
      }
    }
  }

  void _announce(String text) {
    if (!ref.read(voiceEnabledProvider)) return;
    final tts = ref.read(ttsProvider);
    tts.speak(_motivate(text));
  }

  String _motivate(String base) {
    const pep = [
      "You've got this!",
      "Stay strong!",
      "Breathe and push!",
      "Nice pace!",
      "Keep the form!"
    ];
    final m = [...pep]..shuffle(); // new mutable list, single shuffle
    return '$base ${m.first}';
  }
}

// (Optional) If you ever want to pre-build a flat schedule:
class Segment {
  final String label;
  final int seconds;
  final bool isRest;
  const Segment(this.label, this.seconds, this.isRest);
}

List<Segment> buildSchedule(WorkoutPlan plan) {
  final segs = <Segment>[];
  for (var r = 0; r < plan.rounds; r++) {
    for (var i = 0; i < plan.exercises.length; i++) {
      final ex = plan.exercises[i];
      if (ex.seconds > 0) segs.add(Segment(ex.name, ex.seconds, false));
      final lastEx = i == plan.exercises.length - 1;
      if (!lastEx && plan.restBetweenExercises > 0) {
        segs.add(Segment('Rest', plan.restBetweenExercises, true));
      }
    }
    final lastRound = r == plan.rounds - 1;
    if (!lastRound && plan.restBetweenRounds > 0) {
      segs.add(Segment('Round Rest', plan.restBetweenRounds, true));
    }
  }
  return segs;
}
