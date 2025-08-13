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

  String _name = '';
  WorkoutCategory _category = WorkoutCategory.cardio;
  int _rounds = 3; // a)
  int _restBetweenExercises = 15; // c)
  int _restBetweenRounds = 60; // d)
  final List<Exercise> _exercises = [
    // b) + e)
    const Exercise(name: 'Exercise 1', seconds: 30),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create workout')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Plan name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
              onSaved: (v) => _name = (v ?? '').trim(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WorkoutCategory>(
              value: _category,
              items: WorkoutCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                  .toList(),
              onChanged: (c) {
                if (c != null) setState(() => _category = c);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextFormField(
                  initialValue: '$_rounds',
                  decoration: const InputDecoration(labelText: 'Rounds'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    _rounds = n ?? 3;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: '$_restBetweenExercises',
                  decoration: const InputDecoration(
                      labelText: 'Rest between exercises (s)'),
                  keyboardType: TextInputType.number,
                  onSaved: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    _restBetweenExercises = n ?? 15;
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: '$_restBetweenRounds',
              decoration:
                  const InputDecoration(labelText: 'Rest between rounds (s)'),
              keyboardType: TextInputType.number,
              onSaved: (v) {
                final n = int.tryParse((v ?? '').trim());
                _restBetweenRounds = n ?? 60;
              },
            ),
            const SizedBox(height: 16),
            Text('Exercises', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ..._exercises.asMap().entries.map((e) {
              final i = e.key;
              final ex = e.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: ex.name,
                        decoration: const InputDecoration(labelText: 'Name'),
                        onSaved: (v) {
                          final name = (v ?? '').trim();
                          _exercises[i] = Exercise(
                            name:
                                name.isEmpty ? 'Exercise ${i + 1}' : name, // e)
                            seconds: _exercises[i].seconds,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextFormField(
                        initialValue: '${ex.seconds}',
                        decoration:
                            const InputDecoration(labelText: 'Work (s)'),
                        keyboardType: TextInputType.number,
                        onSaved: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          _exercises[i] = Exercise(
                            name: _exercises[i].name,
                            seconds: n ?? 30, // c)
                          );
                        },
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => setState(() => _exercises.removeAt(i)),
                    )
                  ]),
                ),
              );
            }),
            OutlinedButton.icon(
              onPressed: () => setState(() => _exercises.add(
                    Exercise(
                        name: 'Exercise ${_exercises.length + 1}', seconds: 30),
                  )),
              icon: const Icon(Icons.add),
              label: const Text('Add exercise'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save plan'),
              onPressed: () async {
                final f = _form.currentState;
                if (f == null) return;
                if (!f.validate()) return;
                f.save();

                final plan = WorkoutPlan(
                  id: const Uuid().v4(),
                  name: _name,
                  category: _category,
                  exercises: List.of(_exercises),
                  rounds: _rounds,
                  restBetweenExercises: _restBetweenExercises,
                  restBetweenRounds: _restBetweenRounds,
                );

                await ref.read(workoutLibraryProvider.notifier).addPlan(plan);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
