import 'package:flutter/material.dart';
import 'package:app_final_alexm/database_helper.dart';
import 'package:app_final_alexm/weather_service.dart';
import 'package:app_final_alexm/geocoding_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite FFI
  sqfliteFfiInit();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplicación Meteorológica',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService _weatherService = WeatherService();
  final GeocodingService _geocodingService = GeocodingService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String? _ciudad;
  Map<String, dynamic>? _datosMeteorologicos;
  List<Map<String, dynamic>> _weatherRecords = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadWeatherRecords();
  }
// Carga los registros meteorológicos almacenados en la base de datos y los muestra en una lista.
  Future<void> _loadWeatherRecords() async {
    final records = await _databaseHelper.getWeatherRecords();
    setState(() {
      _weatherRecords = records;
    });
  }
  
//Esta función obtiene las coordenadas de la ciudad introducida, 
//consulta los datos meteorológicos y los almacena en la base de datos.
  Future<void> _fetchWeather() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final coordinates = await _geocodingService.getCoordinates(_ciudad!);
        final data = await _weatherService.fetchWeather(coordinates['lat']!, coordinates['lon']!);
        setState(() {
          _datosMeteorologicos = data;
        });
        await _databaseHelper.insertWeather(coordinates['lat']!, coordinates['lon']!, data.toString());
        await _loadWeatherRecords();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicación Meteorológica'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => _ciudad = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduce una ciudad';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchWeather,
                      child: Text('Consultar Tiempo'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _datosMeteorologicos != null
                  ? Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Datos del Tiempo:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Temperatura: ${_datosMeteorologicos!['actual']['temperatura'].toStringAsFixed(2)}°C',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Sensación Térmica: ${_datosMeteorologicos!['actual']['sensacion_termica'].toStringAsFixed(2)}°C',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Humedad: ${_datosMeteorologicos!['actual']['humedad']}%',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Velocidad del Viento: ${_datosMeteorologicos!['actual']['velocidad_viento']} m/s',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Descripción: ${_datosMeteorologicos!['actual']['descripcion']}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true, // Esto permite que ListView funcione dentro de un SingleChildScrollView
                physics: NeverScrollableScrollPhysics(), // Esto desactiva el desplazamiento interno del ListView
                itemCount: _weatherRecords.length,
                itemBuilder: (context, index) {
                  final record = _weatherRecords[index];
                  return Card(
                    child: ListTile(
                      title: Text('Latitud: ${record['latitud']}, Longitud: ${record['longitud']}'),
                      subtitle: Text(record['datos']),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
