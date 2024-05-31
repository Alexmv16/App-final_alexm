import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  final String _apiKey = 'a975f1f1dd5bc78dd422f6875d36cc09';

  Future<Map<String, double>> getCoordinates(String cityName) async {
    final url = 'http://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=$_apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return {
          'lat': data[0]['lat'],
          'lon': data[0]['lon'],
        };
      } else {
        throw Exception('Ciudad no encontrada');
      }
    } else {
      throw Exception('No se pudieron encontrar las coordenadas');
    }
  }
}
