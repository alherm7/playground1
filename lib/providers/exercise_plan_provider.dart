import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExercisePlanNames {
  final String sourceName; // e.g., "Cardio", "Strength", or "Custom"
  final List<String> names;

  const ExercisePlanNames({required this.sourceName, required this.names});

  ExercisePlanNames copyWith({String? sourceName, List<String>? names}) {
    return ExercisePlanNames(
      sourceName: sourceName ?? this.sourceName,
      names: names ?? this.names,
    );
  }

  ExercisePlanNames adjustCount(int exercises) {
    final trimmed = names.take(exercises).toList();
    if (trimmed.length < exercises) {
      for (var i = trimmed.length; i < exercises; i++) {
        trimmed.add('Exercise ${i + 1}');
      }
    }
    return copyWith(names: trimmed);
  }
}

final exercisePlanProvider = StateProvider<ExercisePlanNames>(
    (_) => const ExercisePlanNames(sourceName: 'Custom', names: [
          'Exercise 1',
          'Exercise 2',
          'Exercise 3',
          'Exercise 4',
          'Exercise 5',
        ]));

/// Stores the current selection in the unified dropdown on the start screen.
/// Possible values: 'preset:Cardio', 'preset:Strength', 'preset:Mobility',
/// or 'lib:[planId]'.
final startSelectionProvider = StateProvider<String?>((_) => null);
