import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const _kKey = 'custom_workout_plans_v1';

final workoutLibraryProvider =
    StateNotifierProvider<WorkoutLibrary, List<WorkoutPlan>>(
        (ref) => WorkoutLibrary(ref));

class WorkoutLibrary extends StateNotifier<List<WorkoutPlan>> {
  final Ref ref;
  WorkoutLibrary(this.ref) : super(_defaults) {
    _load();
  }

  static List<WorkoutPlan> get _defaults => [
        WorkoutPlan(
          id: 'builtin-cardio-blaster',
          name: 'Cardio Blaster',
          category: WorkoutCategory.cardio,
          exercises: const [
            Exercise(name: 'Jumping Jacks', seconds: 30),
            Exercise(name: 'High Knees', seconds: 30),
            Exercise(name: 'Burpees', seconds: 30),
          ],
          rounds: 3,
          restBetweenExercises: 15,
          restBetweenRounds: 60,
          builtin: true,
        ),
        WorkoutPlan(
          id: 'builtin-strength-circuit',
          name: 'Strength Circuit',
          category: WorkoutCategory.strength,
          exercises: const [
            Exercise(name: 'Push-ups', seconds: 30),
            Exercise(name: 'Squats', seconds: 40),
            Exercise(name: 'Plank', seconds: 45),
          ],
          rounds: 3,
          restBetweenExercises: 20,
          restBetweenRounds: 60,
          builtin: true,
        ),
        WorkoutPlan(
          id: 'builtin-stretch-flow',
          name: 'Stretch Flow',
          category: WorkoutCategory.mobility,
          exercises: const [
            Exercise(name: 'Hamstring Stretch', seconds: 30),
            Exercise(name: 'Quad Stretch', seconds: 30),
            Exercise(name: 'Shoulder Circles', seconds: 30),
          ],
          rounds: 2,
          restBetweenExercises: 10,
          restBetweenRounds: 30,
          builtin: true,
        ),
      ];

  Future _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return;
    final list =
        (jsonDecode(raw) as List).map((e) => WorkoutPlan.fromJson(e)).toList();
    state = [..._defaults, ...list];
  }

  Future addPlan(WorkoutPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = state.where((p) => !p.builtin).toList();
    final newList = [...custom, plan];
    await prefs.setString(
        _kKey, jsonEncode(newList.map((e) => e.toJson()).toList()));
    state = [..._defaults, ...newList];
  }

  Future deletePlan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final custom = state.where((p) => !p.builtin && p.id != id).toList();
    await prefs.setString(
        _kKey, jsonEncode(custom.map((e) => e.toJson()).toList()));
    state = [..._defaults, ...custom];
  }
}
