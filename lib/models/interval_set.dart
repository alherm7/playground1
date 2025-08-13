// lib/models/interval_set.dart

class IntervalSet {
  final Duration work;
  final Duration rest;
  final int exercises;
  final int rounds;
  final Duration roundReset;

  const IntervalSet({
    required this.work,
    required this.rest,
    required this.exercises,
    required this.rounds,
    required this.roundReset,
  });

  IntervalSet copyWith({
    Duration? work,
    Duration? rest,
    int? exercises,
    int? rounds,
    Duration? roundReset,
  }) {
    return IntervalSet(
      work: work ?? this.work,
      rest: rest ?? this.rest,
      exercises: exercises ?? this.exercises,
      rounds: rounds ?? this.rounds,
      roundReset: roundReset ?? this.roundReset,
    );
  }

  Duration get totalDuration {
    final perRoundSeconds = (exercises * work.inSeconds) +
        ((exercises - 1).clamp(0, 1000000) * rest.inSeconds);
    final totalSeconds = (rounds * perRoundSeconds) +
        ((rounds - 1).clamp(0, 1000000) * roundReset.inSeconds);
    return Duration(seconds: totalSeconds);
  }
}
