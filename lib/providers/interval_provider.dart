//lib/providers/current_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/interval_set.dart';

/// Holds whatever the user has chosen in the “work / rest / rounds” editor.
/// For now we give it simple default values.
final intervalProvider = StateProvider<IntervalSet>(
  (_) => const IntervalSet(
    work: Duration(seconds: 30),
    rest: Duration(seconds: 30),
    exercises: 5,
    rounds: 5,
    roundReset: Duration(seconds: 10),
  ),
);
