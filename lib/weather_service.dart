import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = 'a975f1f1dd5bc78dd422f6875d36cc09';
  final String baseUrl = 'https://api.openweathermap.org/data/3.0/onecall';

 Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final response = await http.get(Uri.parse('$baseUrl?lat=$lat&lon=$lon&appid=$apiKey'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      
      // Convertir temperatura de Kelvin a Celsius
      double tempInCelsius = data['current']['temp'] - 273.15;
      double feelsLikeInCelsius = data['current']['feels_like'] - 273.15;
      
      String descriptionInEnglish = data['current']['weather'][0]['description'];
      String descriptionInSpanish = translateDescription(descriptionInEnglish);
      
      Map<String, dynamic> filteredData = {
        'latitud': data['lat'],
        'longitud': data['lon'],
        'zona_horaria': data['timezone'],
        'actual': {
          'temperatura': tempInCelsius,
          'sensacion_termica': feelsLikeInCelsius,
          'humedad': data['current']['humidity'],
          'velocidad_viento': data['current']['wind_speed'],
          'descripcion': descriptionInSpanish,
        }
      };
      return filteredData;
    } else {
      throw Exception('Error al cargar datos meteorológicos');
    }
  }

  String translateDescription(String description) {
    Map<String, String> translations = {
      'clear sky': 'cielo despejado',
      'few clouds': 'pocas nubes',
      'scattered clouds': 'nubes dispersas',
      'broken clouds': 'nubes rotas',
      'shower rain': 'lluvia de ducha',
      'rain': 'lluvia',
      'thunderstorm': 'tormenta',
      'snow': 'nieve',
      'mist': 'neblina'
    };

    return translations[description] ?? description;
  }
}