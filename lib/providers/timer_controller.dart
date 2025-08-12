// providers/timer_controller.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/tts_service.dart';

enum SessionState { idle, running, paused, finished }

class TimerSession {
  final WorkoutPlan plan;
  final int roundIndex; // 0-based
  final int exerciseIndex; // 0-based
  final bool isRest;
  final int secondsLeft;
  final int totalElapsed;
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

  String get currentLabel =>
      isRest ? 'Rest' : plan.exercises[exerciseIndex].name;

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
    (ref) => TimerController(ref));

class TimerController extends StateNotifier<TimerSession?> {
  final Ref ref;
  Timer? _ticker;

  TimerController(this.ref) : super(null);

  void start(WorkoutPlan plan) {
    _ticker?.cancel();
    state = TimerSession(
      plan: plan,
      roundIndex: 0,
      exerciseIndex: 0,
      isRest: false,
      secondsLeft: plan.exercises.first.seconds,
      totalElapsed: 0,
      state: SessionState.running,
    );
    _announce(
        'Starting ${plan.name}. Round 1 of ${plan.rounds}. First: ${plan.exercises.first.name}.');
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

  void _tick() {
    if (state == null) return;
    final s = state!;
    if (s.secondsLeft <= 1) {
      _advance();
    } else {
      final next = s.copyWith(
          secondsLeft: s.secondsLeft - 1, totalElapsed: s.totalElapsed + 1);
      state = next;
      if ([3, 2, 1].contains(next.secondsLeft)) {
        _announce('${next.secondsLeft}');
      }
    }
  }

  void _advance() {
    final s = state!;
    final plan = s.plan;

    // Transition logic
    if (!s.isRest) {
      // Finished an exercise -> go to rest (between exercises) or round rest
      final isLastExercise = s.exerciseIndex == plan.exercises.length - 1;
      if (!isLastExercise) {
        // rest between exercises
        final nextExercise = s.exerciseIndex + 1;
        state = s.copyWith(
          isRest: true,
          secondsLeft: plan.restBetweenExercises,
          totalElapsed: s.totalElapsed + 1,
          exerciseIndex:
              nextExercise, // point to upcoming exercise for "Next:" label
        );
        _announce(
            'Rest ${plan.restBetweenExercises} seconds. Next: ${plan.exercises[nextExercise].name}.');
      } else {
        // rest between rounds or finish
        final isLastRound = s.roundIndex == plan.rounds - 1;
        if (!isLastRound) {
          state = s.copyWith(
            isRest: true,
            secondsLeft: plan.restBetweenRounds,
            totalElapsed: s.totalElapsed + 1,
            roundIndex: s.roundIndex + 1, // upcoming round index
            exerciseIndex: 0,
          );
          _announce(
              'Round ${s.roundIndex + 1} complete. Rest ${plan.restBetweenRounds} seconds.');
        } else {
          _ticker?.cancel();
          state = s.copyWith(
              state: SessionState.finished, totalElapsed: s.totalElapsed + 1);
          _announce('Workout complete. Awesome job!');
        }
      }
    } else {
      // Coming out of a rest -> start the designated exercise
      final currentExercise = s.plan.exercises[s.exerciseIndex];
      state = s.copyWith(
          isRest: false,
          secondsLeft: currentExercise.seconds,
          totalElapsed: s.totalElapsed + 1);
      _announce('Go: ${currentExercise.name}!');
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
    pep.shuffle();
    return '$base ${pep.first}';
  }
}

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
      segs.add(Segment(ex.name, ex.seconds, false)); // work
      final isLastExercise = i == plan.exercises.length - 1;
      if (!isLastExercise && plan.restBetweenExercises > 0) {
        segs.add(Segment('Rest', plan.restBetweenExercises, true));
      }
    }
    final isLastRound = r == plan.rounds - 1;
    if (!isLastRound && plan.restBetweenRounds > 0) {
      segs.add(Segment('Round Rest', plan.restBetweenRounds, true));
    }
  }
  return segs;
}
