import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_library.dart';
import '../providers/timer_controller.dart';
import 'plan_builder_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(workoutLibraryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workout Library')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: plans.length + 1, // extra card for "Create"
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, index) {
          if (index == 0) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Create a custom workout'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PlanBuilderScreen()),
                ),
              ),
            );
          }

          final p = plans[index - 1];
          return Card(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                '${p.category.name} • ${p.exercises.length} exercises • ${p.rounds} rounds',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Select',
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () =>
                        ref.read(currentPlanProvider.notifier).state = p,
                  ),
                  if (!p.builtin)
                    IconButton(
                      tooltip: 'Delete',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(workoutLibraryProvider.notifier)
                          .deletePlan(p.id),
                    ),
                ],
              ),
              onTap: () => ref.read(currentPlanProvider.notifier).state = p,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PlanBuilderScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Create plan'),
      ),
    );
  }
}
