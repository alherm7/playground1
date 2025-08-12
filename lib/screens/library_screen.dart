import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_library.dart';
import '../providers/timer_controller.dart';
import 'plan_builder_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  ListView(
    children: [
      Card(
        child: ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Create a custom workout'),
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlanBuilderScreen())),
        ),
      ),
      // ... then your existing list of plans
    ],
  )


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(workoutLibraryProvider);
    return Scaffold(
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final p = plans[i];
          return Card(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                  '${p.category.name} • ${p.exercises.length} exercises • ${p.rounds} rounds'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () =>
                        ref.read(currentPlanProvider.notifier).state = p,
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Select',
                  ),
                  if (!p.builtin)
                    IconButton(
                      onPressed: () => ref
                          .read(workoutLibraryProvider.notifier)
                          .deletePlan(p.id),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PlanBuilderScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create plan'),
      ),
    );
  }
}
