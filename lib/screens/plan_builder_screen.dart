import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/workout_library.dart';

class PlanBuilderScreen extends ConsumerStatefulWidget {
  const PlanBuilderScreen({super.key});

  @override
  ConsumerState<PlanBuilderScreen> createState() => _PlanBuilderScreenState();
}

class _PlanBuilderScreenState extends ConsumerState<PlanBuilderScreen> {
  final _form = GlobalKey<FormState>();
  final _uuid = const Uuid();
  String _name = '';
  WorkoutCategory _category = WorkoutCategory.cardio;
  int _rounds = 3;
  int _restBetweenExercises = 15;
  int _restBetweenRounds = 60;
  final List<Exercise> _exercises = [const Exercise(name: 'New Exercise', seconds: 30)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create plan')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Plan name'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Enter a name' : null,
              onSaved: (v) => _name = v!.trim(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<WorkoutCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: WorkoutCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (c) => setState(() => _category = c!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '$_rounds',
                    decoration: const InputDecoration(labelText: 'Rounds'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _rounds = int.tryParse(v ?? '3') ?? 3,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: '$_restBetweenExercises',
                    decoration: const InputDecoration(labelText: 'Rest between exercises (s)'),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => _restBetweenExercises = int.tryParse(v ?? '15') ?? 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: '$_restBetweenRounds',
              decoration: const InputDecoration(labelText: 'Rest between rounds (s)'),
              keyboardType: TextInputType.number,
              onSaved: (v) => _restBetweenRounds = int.tryParse(v ?? '60') ?? 60,
            ),
            const SizedBox(height: 16),
            Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: ex.name,
                          decoration: const InputDecoration(labelText: 'Name'),
                          onSaved: (v) => _exercises[i] = Exercise(name: v!.trim().isEmpty ? 'Exercise' : v!.trim(), seconds: _exercises[i].seconds),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          initialValue: '${ex.seconds}',
                          decoration: const InputDecoration(labelText: 'Seconds'),
                          keyboardType: TextInputType.number,
                          onSaved: (v) => _exercises[i] = Exercise(name: _exercises[i].name, seconds: int.tryParse(v ?? '30') ?? 30),
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _exercises.removeAt(i)),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Remove',
                      )
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => _exercises.add(const Exercise(name: 'New Exercise', seconds: 30))),
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                _form.currentState!.save();
                final plan = WorkoutPlan(
                  id: _uuid.v4(),
                  name: _name,
                  category: _category,
                  exercises: List.of(_exercises),
                  rounds: _rounds,
                  restBetweenExercises: _restBetweenExercises,
                  restBetweenRounds: _restBetweenRounds,
                );
                await ref.read(workoutLibraryProvider.notifier).addPlan(plan);
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.save),
              label: const Text('Save plan'),
            ),
          ],
        ),
      ),
    );
  }
}
