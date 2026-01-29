import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double precipitation;
  final double rainProbability;

  WeatherData({
    required this.temperature,
    required this.precipitation,
    required this.rainProbability,
  });
}

class WeatherService {
  static const String _baseUrl = "https://api.open-meteo.com/v1/forecast";

  Future<WeatherData?> fetchWeather(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          "$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,precipitation&hourly=precipitation_probability&forecast_days=1"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData(
          temperature: data['current']['temperature_2m'],
          precipitation: data['current']['precipitation'],
          rainProbability: data['hourly']['precipitation_probability'][0].toDouble(),
        );
      }
    } catch (e) {
      print("Erro ao buscar clima: $e");
    }
    return null;
  }
}
