import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_controller.dart';
import '../providers/workout_library.dart';
import '../providers/logging.dart';
import '../models/models.dart';
import '../widgets/progress_ring.dart';
import 'library_screen.dart';
import 'history_screen.dart';

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
            onPressed: () => ref.read(voiceEnabledProvider.notifier).state = !voice,
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
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Library'),
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

    if (session == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Choose a workout', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            DropdownButton<WorkoutPlan>(
              isExpanded: true,
              value: plan,
              hint: const Text('Select a plan'),
              items: lib.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} • ${p.category.name}'))).toList(),
              onChanged: (p) => ref.read(currentPlanProvider.notifier).state = p,
            ),
            const SizedBox(height: 24),
            Center(
              child: FilledButton.icon(
                onPressed: plan == null ? null : () => ref.read(timerProvider.notifier).start(plan!),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ),
          ],
        ),
      );
    }

    final s = session!;
    

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
          Text('Now: ${s.currentLabel}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (s.exerciseIndex < s.plan.exercises.length - 1)
            Text('Next: ${s.plan.exercises[s.exerciseIndex + 1].name}'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () => ref.read(timerProvider.notifier).pause(),
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
              ),
              const SizedBox(width: 12),
              FilledButton.tonalIcon(
                onPressed: () => ref.read(timerProvider.notifier).resume(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final controller = ref.read(timerProvider.notifier);
                  final startedAt = DateTime.now().subtract(Duration(seconds: s.totalElapsed));
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
        content: TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'How did it go?')), 
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Skip')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim().isEmpty ? null : controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
  }
}
