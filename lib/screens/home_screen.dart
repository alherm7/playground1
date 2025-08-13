import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_controller.dart';
import '../providers/workout_library.dart';
import '../providers/logging.dart';
import '../models/models.dart';
import '../widgets/progress_ring.dart';
import 'library_screen.dart';
import 'history_screen.dart';
import '../providers/interval_provider.dart';
import '../models/interval_set.dart';
import '../providers/exercise_plan_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(timerProvider);
    final plan = ref.watch(currentPlanProvider);
    final voice = ref.watch(voiceEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Timer'),
        actions: [
          IconButton(
            tooltip: voice ? 'Voice: on' : 'Voice: off',
            onPressed: () =>
                ref.read(voiceEnabledProvider.notifier).state = !voice,
            icon: Icon(voice ? Icons.record_voice_over : Icons.voice_over_off),
          )
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _TimerTab(session: session, plan: plan),
          const LibraryScreen(),
          const HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Timer'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class _TimerTab extends ConsumerWidget {
  final TimerSession? session;
  final WorkoutPlan? plan;
  const _TimerTab({required this.session, required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lib = ref.watch(workoutLibraryProvider);
    final exercisePlan = ref.watch(exercisePlanProvider);
    final selection = ref.watch(startSelectionProvider);

    if (session == null) {
      final intervals = ref.watch(intervalProvider);
      final total = intervals.totalDuration;
      String fmt(Duration d) {
        String two(int v) => v.toString().padLeft(2, '0');
        final m = d.inMinutes;
        final s = d.inSeconds % 60;
        return '${two(m)}:${two(s)}';
      }

      Future<void> pickWork() async {
        final d = await _pickDuration(context, intervals.work);
        if (d != null) {
          ref.read(intervalProvider.notifier).state =
              intervals.copyWith(work: d);
        }
      }

      Future<void> pickRest() async {
        final d = await _pickDuration(context, intervals.rest);
        if (d != null) {
          ref.read(intervalProvider.notifier).state =
              intervals.copyWith(rest: d);
        }
      }

      Future<void> pickRoundReset() async {
        final d = await _pickDuration(context, intervals.roundReset);
        if (d != null) {
          ref.read(intervalProvider.notifier).state =
              intervals.copyWith(roundReset: d);
        }
      }

      Future<void> pickExercises() async {
        final v = await _pickInt(context,
            title: 'Exercises', initial: intervals.exercises, min: 1, max: 30);
        if (v != null) {
          ref.read(intervalProvider.notifier).state =
              intervals.copyWith(exercises: v);
          // Keep the current source name, just adjust the list length
          final current = ref.read(exercisePlanProvider);
          ref.read(exercisePlanProvider.notifier).state =
              current.adjustCount(v);
        }
      }

      Future<void> pickRounds() async {
        final v = await _pickInt(context,
            title: 'Rounds', initial: intervals.rounds, min: 1, max: 30);
        if (v != null) {
          ref.read(intervalProvider.notifier).state =
              intervals.copyWith(rounds: v);
        }
      }

      WorkoutPlan buildPlanFromIntervals(IntervalSet i) {
        final planNames =
            ref.read(exercisePlanProvider).adjustCount(i.exercises).names;
        final exercises = List<Exercise>.generate(
          i.exercises,
          (index) =>
              Exercise(name: planNames[index], seconds: i.work.inSeconds),
        );
        return WorkoutPlan(
          id: 'quick',
          name: ref.read(exercisePlanProvider).sourceName,
          category: WorkoutCategory.cardio,
          exercises: exercises,
          rounds: i.rounds,
          restBetweenExercises: i.rest.inSeconds,
          restBetweenRounds: i.roundReset.inSeconds,
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Text('Interval Timer',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                fmt(total),
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: InkResponse(
                onTap: () {
                  final chosenPlan = buildPlanFromIntervals(intervals);
                  ref.read(timerProvider.notifier).start(chosenPlan);
                },
                radius: 56,
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.play_arrow, size: 56),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  Text('Workout selection',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selection,
                    hint: const Text('Choose a preset or a saved plan'),
                    items: [
                      const DropdownMenuItem(
                          value: 'preset:Cardio',
                          child: Text('Preset – Cardio')),
                      const DropdownMenuItem(
                          value: 'preset:Strength',
                          child: Text('Preset – Strength')),
                      const DropdownMenuItem(
                          value: 'preset:Mobility',
                          child: Text('Preset – Mobility')),
                      const DropdownMenuItem(
                          enabled: false,
                          value: 'divider',
                          child: Divider(height: 1)),
                      ...lib.map((p) => DropdownMenuItem<String>(
                            value: 'lib:${p.id}',
                            child: Text('Library – ${p.name}'),
                          )),
                    ],
                    onChanged: (key) {
                      if (key == null) return;
                      ref.read(startSelectionProvider.notifier).state = key;
                      if (key.startsWith('preset:')) {
                        final preset = key.split(':').last;
                        if (preset == 'Cardio') {
                          ref.read(intervalProvider.notifier).state =
                              intervals.copyWith(
                            work: const Duration(seconds: 50),
                            rest: const Duration(seconds: 10),
                            exercises: 5,
                            rounds: 5,
                            roundReset: const Duration(seconds: 5),
                          );
                          ref.read(exercisePlanProvider.notifier).state =
                              const ExercisePlanNames(
                            sourceName: 'Cardio',
                            names: [
                              'Jumping Jacks',
                              'High Knees',
                              'Mountain Climbers',
                              'Burpees',
                              'Skaters',
                            ],
                          );
                        } else if (preset == 'Strength') {
                          ref.read(intervalProvider.notifier).state =
                              intervals.copyWith(
                            work: const Duration(seconds: 40),
                            rest: const Duration(seconds: 20),
                            exercises: 5,
                            rounds: 4,
                            roundReset: const Duration(seconds: 30),
                          );
                          ref.read(exercisePlanProvider.notifier).state =
                              const ExercisePlanNames(
                            sourceName: 'Strength',
                            names: [
                              'Push-ups',
                              'Squats',
                              'Lunges',
                              'Plank',
                              'Supermans',
                            ],
                          );
                        } else if (preset == 'Mobility') {
                          ref.read(intervalProvider.notifier).state =
                              intervals.copyWith(
                            work: const Duration(seconds: 30),
                            rest: const Duration(seconds: 15),
                            exercises: 5,
                            rounds: 3,
                            roundReset: const Duration(seconds: 20),
                          );
                          ref.read(exercisePlanProvider.notifier).state =
                              const ExercisePlanNames(
                            sourceName: 'Mobility',
                            names: [
                              'Neck Rolls',
                              'Shoulder Circles',
                              'Hip Openers',
                              'Hamstring Stretch',
                              'Calf Stretch',
                            ],
                          );
                        }
                        // We intentionally do not set a library plan selection
                        ref.read(currentPlanProvider.notifier).state = null;
                      } else if (key.startsWith('lib:')) {
                        final id = key.substring(4);
                        final p = lib.firstWhere((e) => e.id == id,
                            orElse: () => lib.first);
                        // Prefill selectors and names from the library plan
                        ref.read(intervalProvider.notifier).state =
                            intervals.copyWith(
                          work: Duration(
                              seconds: p.exercises.isNotEmpty
                                  ? p.exercises.first.seconds
                                  : 30),
                          rest: Duration(seconds: p.restBetweenExercises),
                          exercises: p.exercises.length,
                          rounds: p.rounds,
                          roundReset: Duration(seconds: p.restBetweenRounds),
                        );
                        ref.read(exercisePlanProvider.notifier).state =
                            ExercisePlanNames(
                          sourceName: p.name,
                          names: p.exercises.map((e) => e.name).toList(),
                        );
                        // Ensure we run with current selectors, not the raw plan
                        ref.read(currentPlanProvider.notifier).state = null;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _ConfigTile(
                    color: Colors.green.shade800,
                    icon: Icons.play_circle_fill,
                    label: 'Work',
                    value: fmt(intervals.work),
                    onTap: pickWork,
                  ),
                  _ConfigTile(
                    color: Colors.red.shade900,
                    icon: Icons.pause_circle_filled,
                    label: 'Rest',
                    value: fmt(intervals.rest),
                    onTap: pickRest,
                  ),
                  _ConfigTile(
                    color: Colors.grey.shade800,
                    icon: Icons.bolt,
                    label: 'Exercises',
                    value: '${intervals.exercises}',
                    onTap: pickExercises,
                  ),
                  _ConfigTile(
                    color: Colors.indigo.shade900,
                    icon: Icons.refresh,
                    label: 'Rounds',
                    value: '${intervals.rounds}x',
                    onTap: pickRounds,
                  ),
                  _ConfigTile(
                    color: Colors.brown.shade800,
                    icon: Icons.timer,
                    label: 'Round Reset',
                    value: fmt(intervals.roundReset),
                    onTap: pickRoundReset,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final names = await _editExerciseNames(context, ref);
                      if (names != null) {
                        ref.read(exercisePlanProvider.notifier).state =
                            ExercisePlanNames(
                                sourceName: 'Custom', names: names);
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(
                        'Edit exercise names (${exercisePlan.sourceName})'),
                  ),
                  // Library dropdown removed; unified above
                ],
              ),
            ),
          ],
        ),
      );
    }

    final s = session!;
    final denom = s.isRest
        ? (s.exerciseIndex == 0
            ? s.plan.restBetweenRounds.toDouble()
            : s.plan.restBetweenExercises.toDouble())
        : s.plan.exercises[s.exerciseIndex].seconds.toDouble();
    final progress = s.secondsLeft / denom;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(s.plan.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('Round ${s.roundIndex + 1} of ${s.plan.rounds}'),
          const SizedBox(height: 12),
          ProgressRing(progress: progress, centerText: '${s.secondsLeft}s'),
          const SizedBox(height: 8),
          Text('Now: ${s.currentLabel}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (s.exerciseIndex < s.plan.exercises.length - 1)
            Text('Next: ${s.plan.exercises[s.exerciseIndex + 1].name}'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  final ctrl = ref.read(timerProvider.notifier);
                  if (s.state == SessionState.running) {
                    ctrl.pause();
                  } else if (s.state == SessionState.paused) {
                    ctrl.resume();
                  }
                },
                icon: Icon(s.state == SessionState.running
                    ? Icons.pause
                    : Icons.play_arrow),
                label:
                    Text(s.state == SessionState.running ? 'Pause' : 'Resume'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => ref.read(timerProvider.notifier).skip(),
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final controller = ref.read(timerProvider.notifier);
                  final startedAt = DateTime.now()
                      .subtract(Duration(seconds: s.totalElapsed));
                  controller.stop();
                  String? notes = await _askNotes(context);
                  await ref.read(logsProvider.notifier).addLog(
                        planName: s.plan.name,
                        startedAt: startedAt,
                        totalSeconds: s.totalElapsed,
                        roundsCompleted: s.roundIndex + 1,
                        notes: notes,
                      );
                },
                icon: const Icon(Icons.stop),
                label: const Text('Stop'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _askNotes(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add notes'),
        content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'How did it go?')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Skip')),
          FilledButton(
              onPressed: () => Navigator.pop(
                  ctx,
                  controller.text.trim().isEmpty
                      ? null
                      : controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ConfigTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: Theme.of(context).textTheme.titleLarge),
        trailing: Text(value, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
      ),
    );
  }
}

Future<Duration?> _pickDuration(BuildContext context, Duration initial) async {
  Duration selected = initial;
  return showModalBottomSheet<Duration>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: SizedBox(
          height: 280,
          child: Column(
            children: [
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: initial,
                  onTimerDurationChanged: (d) => selected = d,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(selected),
                    child: const Text('Done'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<int?> _pickInt(BuildContext context,
    {required String title,
    required int initial,
    required int min,
    required int max}) async {
  final controller = TextEditingController(text: initial.toString());
  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(
            signed: false, decimal: false),
        decoration: InputDecoration(hintText: '$min..$max'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final v = int.tryParse(controller.text.trim());
            if (v == null) {
              Navigator.pop(ctx);
              return;
            }
            final clamped = v.clamp(min, max);
            Navigator.pop(ctx, clamped);
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

Future<List<String>?> _editExerciseNames(
    BuildContext context, WidgetRef ref) async {
  final intervals = ref.read(intervalProvider);
  final current =
      ref.read(exercisePlanProvider).adjustCount(intervals.exercises).names;
  final controllers =
      current.map((n) => TextEditingController(text: n)).toList();
  return showDialog<List<String>>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit exercise names'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < controllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: controllers[i],
                  decoration: InputDecoration(
                    labelText: 'Exercise ${i + 1}',
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final list = controllers.map((c) => c.text.trim()).toList();
            for (var i = 0; i < list.length; i++) {
              if (list[i].isEmpty) list[i] = 'Exercise ${i + 1}';
            }
            Navigator.pop(ctx, list);
          },
          child: const Text('Save'),
        )
      ],
    ),
  );
}
