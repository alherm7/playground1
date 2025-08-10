import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

final logsProvider = StateNotifierProvider<WorkoutLogs, List<WorkoutLog>>(
    (ref) => WorkoutLogs(ref));
const _uuid = Uuid();
const _kLogsKey = 'workout_logs_v1';

class WorkoutLogs extends StateNotifier<List<WorkoutLog>> {
  final Ref ref;
  WorkoutLogs(this.ref) : super(const []) {
    _load();
  }

  Future _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLogsKey);
    if (raw == null) return;
    final list =
        (jsonDecode(raw) as List).map((e) => WorkoutLog.fromJson(e)).toList();
    state = list;
  }

  Future<void> addLog(
      {required String planName,
      required DateTime startedAt,
      required int totalSeconds,
      required int roundsCompleted,
      String? notes}) async {
    double? lat, lon, temp, wind;
    int? code;

    try {
      final position = await LocationService().getPosition();
      if (position != null) {
        lat = position.latitude;
        lon = position.longitude;
        final w = await WeatherService().fetch(lat, lon);
        if (w != null) {
          temp = w.temperatureC;
          wind = w.windKph;
          code = w.weatherCode;
        }
      }
    } catch (_) {}

    final log = WorkoutLog(
      id: _uuid.v4(),
      planName: planName,
      startedAt: startedAt,
      totalSeconds: totalSeconds,
      roundsCompleted: roundsCompleted,
      latitude: lat,
      longitude: lon,
      temperatureC: temp,
      windKph: wind,
      weatherCode: code,
      notes: notes,
    );

    final newList = [log, ...state];
    state = newList;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kLogsKey, jsonEncode(newList.map((e) => e.toJson()).toList()));
  }
}
