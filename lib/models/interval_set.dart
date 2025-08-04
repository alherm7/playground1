// lib/models/interval_set.dart
class IntervalSet {
  final Duration work;
  final Duration rest;
  final int rounds;

  const IntervalSet({
    required this.work,
    required this.rest,
    required this.rounds,
  });
}
