import 'package:universal_io/io.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart'; // Re-added
import '../models/plant.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gharsa.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Web Support: Return Unimplemented or empty
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web');
    }

    // Check if running on Desktop (Windows/Linux/macOS)
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    final db = await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );

    // Check if table is empty and seed if needed (fix for existing empty DBs)
    // Removed auto-seeding logic
    return db;
  }

  // Batch Insert/Update for syncing with Firebase
  Future<void> upsertPlants(List<Plant> plants) async {
    // If Web, we don't use SQLite.
    if (kIsWeb) return;

    final db = await instance.database;
    final batch = db.batch();

    for (var plant in plants) {
      batch.insert(
        'plants',
        plant.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE plants ADD COLUMN temperature TEXT');
      await db.execute('ALTER TABLE plants ADD COLUMN light TEXT');
      await db.execute('ALTER TABLE plants ADD COLUMN water TEXT');
      await db.execute('ALTER TABLE plants ADD COLUMN soil TEXT');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE plants ADD COLUMN waterLevel REAL DEFAULT 0.5',
      );
      await db.execute(
        'ALTER TABLE plants ADD COLUMN lightLevel REAL DEFAULT 0.5',
      );
      await db.execute(
        'ALTER TABLE plants ADD COLUMN humidityLevel REAL DEFAULT 0.5',
      );
      await db.execute(
        'ALTER TABLE plants ADD COLUMN fertilizerLevel REAL DEFAULT 0.3',
      );
      await db.execute(
        'ALTER TABLE plants ADD COLUMN plantAge INTEGER DEFAULT 12',
      );
    }
    if (oldVersion < 4) {
      // Delete all old plants
      await db.delete('plants');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE plants (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      price REAL NOT NULL,
      quantity INTEGER NOT NULL,
      imageUrl TEXT NOT NULL,
      description TEXT NOT NULL,
      category TEXT NOT NULL,
      discount REAL,
      isFavorite INTEGER NOT NULL,
      temperature TEXT,
      light TEXT,
      water TEXT,
      soil TEXT,
      waterLevel REAL,
      lightLevel REAL,
      humidityLevel REAL,
      fertilizerLevel REAL,
      plantAge INTEGER
    )
    ''');

    // Seed initial data removed
  }

  Future<int> insertPlant(Plant plant) async {
    final db = await instance.database;
    return await db.insert('plants', plant.toMap());
  }

  Future<List<Plant>> getAllPlants() async {
    final db = await instance.database;
    final result = await db.query('plants');
    return result.map((json) => Plant.fromMap(json)).toList();
  }

  Future<int> updateQuantity(int id, int newQuantity) async {
    final db = await instance.database;
    return await db.update(
      'plants',
      {'quantity': newQuantity},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'plants',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Plant>> searchPlants(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'plants',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((json) => Plant.fromMap(json)).toList();
  }
}
