import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherReading {
  final double temperatureC;
  final double windKph;
  final int weatherCode;
  const WeatherReading({required this.temperatureC, required this.windKph, required this.weatherCode});
}

class WeatherService {
  Future<WeatherReading?> fetch(double lat, double lon) async {
    final uri = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final j = jsonDecode(res.body);
    final cw = j['current_weather'];
    return WeatherReading(
      temperatureC: (cw['temperature'] as num).toDouble(),
      windKph: ((cw['windspeed'] as num).toDouble() * 1.0),
      weatherCode: cw['weathercode'] as int,
    );
  }
}
