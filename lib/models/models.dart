enum WorkoutCategory { cardio, strength, mobility }

class Exercise {
  final String name;
  final int seconds;
  const Exercise({required this.name, required this.seconds});

  Map<String, dynamic> toJson() => {'name': name, 'seconds': seconds};
  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(name: j['name'], seconds: j['seconds']);
}

class WorkoutPlan {
  final String id;
  final String name;
  final WorkoutCategory category;
  final List<Exercise> exercises;
  final int rounds;
  final int restBetweenExercises; // seconds
  final int restBetweenRounds; // seconds
  final bool builtin;

  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.category,
    required this.exercises,
    this.rounds = 3,
    this.restBetweenExercises = 15,
    this.restBetweenRounds = 60,
    this.builtin = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'rounds': rounds,
        'restBetweenExercises': restBetweenExercises,
        'restBetweenRounds': restBetweenRounds,
        'builtin': builtin,
      };

  factory WorkoutPlan.fromJson(Map<String, dynamic> j) => WorkoutPlan(
        id: j['id'],
        name: j['name'],
        category: WorkoutCategory.values.firstWhere((e) => e.name == j['category'], orElse: () => WorkoutCategory.cardio),
        exercises: (j['exercises'] as List).map((e) => Exercise.fromJson(e)).toList(),
        rounds: j['rounds'],
        restBetweenExercises: j['restBetweenExercises'],
        restBetweenRounds: j['restBetweenRounds'],
        builtin: j['builtin'] ?? false,
      );
}

class WorkoutLog {
  final String id;
  final String planName;
  final DateTime startedAt;
  final int totalSeconds;
  final int roundsCompleted;
  final double? latitude;
  final double? longitude;
  final double? temperatureC;
  final double? windKph;
  final int? weatherCode;
  final String? notes;

  const WorkoutLog({
    required this.id,
    required this.planName,
    required this.startedAt,
    required this.totalSeconds,
    required this.roundsCompleted,
    this.latitude,
    this.longitude,
    this.temperatureC,
    this.windKph,
    this.weatherCode,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'planName': planName,
        'startedAt': startedAt.toIso8601String(),
        'totalSeconds': totalSeconds,
        'roundsCompleted': roundsCompleted,
        'latitude': latitude,
        'longitude': longitude,
        'temperatureC': temperatureC,
        'windKph': windKph,
        'weatherCode': weatherCode,
        'notes': notes,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> j) => WorkoutLog(
        id: j['id'],
        planName: j['planName'],
        startedAt: DateTime.parse(j['startedAt']),
        totalSeconds: j['totalSeconds'],
        roundsCompleted: j['roundsCompleted'],
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        temperatureC: (j['temperatureC'] as num?)?.toDouble(),
        windKph: (j['windKph'] as num?)?.toDouble(),
        weatherCode: j['weatherCode'],
        notes: j['notes'],
      );
}
