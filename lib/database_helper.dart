import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await databaseFactory.getDatabasesPath(), 'weather.db');
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) {
          return db.execute(
            "CREATE TABLE weather(id INTEGER PRIMARY KEY, latitud REAL, longitud REAL, datos TEXT)",
          );
        },
      ),
    );
  }

  Future<void> insertWeather(double lat, double lon, String data) async {
    final db = await database;
    await db.insert(
      'weather',
      {'latitud': lat, 'longitud': lon, 'datos': data},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWeatherRecords() async {
    final db = await database;
    return await db.query('weather', orderBy: 'id DESC');
  }
}
