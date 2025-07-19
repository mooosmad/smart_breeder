import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:smart_breeder/data/models/animal_model.dart';
import 'package:smart_breeder/data/models/vaccination_schedule_model.dart';
import 'package:smart_breeder/data/models/chat_message_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_breeder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Table des animaux
    await db.execute('''
      CREATE TABLE animals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        subType TEXT NOT NULL,
        count INTEGER NOT NULL,
        ageInMonths INTEGER NOT NULL,
        category TEXT NOT NULL,
        breed TEXT,
        physiologicalStage TEXT NOT NULL,
        averageWeight REAL,
        productionObjective TEXT NOT NULL,
        healthStatus TEXT NOT NULL,
        location TEXT NOT NULL,
        temperature REAL,
        housingType TEXT NOT NULL,
        soilType TEXT NOT NULL,
        availableResources TEXT NOT NULL,
        workforce INTEGER NOT NULL,
        feedingType TEXT NOT NULL,
        feedingFrequency INTEGER NOT NULL,
        performanceHistory TEXT,
        timeAvailability TEXT NOT NULL,
        specificConstraints TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        arrivalStatus TEXT,
        origin TEXT,
        buildingArea REAL,
        budget TEXT
      )
    ''');

    // Table des vaccinations
    await db.execute('''
      CREATE TABLE vaccination_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animalId INTEGER NOT NULL,
        vaccineName TEXT NOT NULL,
        vaccineType TEXT NOT NULL,
        scheduledDate TEXT NOT NULL,
        completedDate TEXT,
        status TEXT NOT NULL,
        notes TEXT,
        estimatedCost REAL,
        actualCost REAL,
        priority TEXT NOT NULL,
        veterinaryAdvice TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (animalId) REFERENCES animals (id) ON DELETE CASCADE
      )
    ''');

    // Table des messages chat
    await db.execute('''
      CREATE TABLE chat_messages (
        id TEXT PRIMARY KEY,
        message TEXT NOT NULL,
        sender TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        audioPath TEXT,
        isVoiceMessage INTEGER NOT NULL DEFAULT 0,
        animalContext TEXT
      )
    ''');
  }

  // CRUD pour les animaux
  Future<int> insertAnimal(AnimalModel animal) async {
    final db = await database;
    return await db.insert('animals', animal.toJson());
  }

  Future<List<AnimalModel>> getAllAnimals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('animals');
    return List.generate(maps.length, (i) => AnimalModel.fromJson(maps[i]));
  }

  Future<AnimalModel?> getAnimalById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return AnimalModel.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateAnimal(AnimalModel animal) async {
    final db = await database;
    return await db.update(
      'animals',
      animal.toJson(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  Future<int> deleteAnimal(int id) async {
    final db = await database;
    return await db.delete(
      'animals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD pour les vaccinations
  Future<int> insertVaccinationSchedule(VaccinationScheduleModel schedule) async {
    final db = await database;
    return await db.insert('vaccination_schedules', schedule.toJson());
  }

  Future<List<VaccinationScheduleModel>> getVaccinationSchedules({int? animalId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    
    if (animalId != null) {
      maps = await db.query(
        'vaccination_schedules',
        where: 'animalId = ?',
        whereArgs: [animalId],
        orderBy: 'scheduledDate ASC',
      );
    } else {
      maps = await db.query(
        'vaccination_schedules',
        orderBy: 'scheduledDate ASC',
      );
    }
    
    return List.generate(maps.length, (i) => VaccinationScheduleModel.fromJson(maps[i]));
  }

  Future<List<VaccinationScheduleModel>> getUpcomingVaccinations() async {
    final db = await database;
    final now = DateTime.now();
    final upcoming = now.add(const Duration(days: 7));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'vaccination_schedules',
      where: 'scheduledDate BETWEEN ? AND ? AND status != ?',
      whereArgs: [now.toIso8601String(), upcoming.toIso8601String(), 'completed'],
      orderBy: 'scheduledDate ASC',
    );
    
    return List.generate(maps.length, (i) => VaccinationScheduleModel.fromJson(maps[i]));
  }

  Future<int> updateVaccinationSchedule(VaccinationScheduleModel schedule) async {
    final db = await database;
    return await db.update(
      'vaccination_schedules',
      schedule.toJson(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  // CRUD pour les messages chat
  Future<int> insertChatMessage(ChatMessageModel message) async {
    final db = await database;
    return await db.insert('chat_messages', message.toJson());
  }

  Future<List<ChatMessageModel>> getChatMessages({int limit = 50}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_messages',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) => ChatMessageModel.fromJson(maps[i])).reversed.toList();
  }

  Future<int> clearChatHistory() async {
    final db = await database;
    return await db.delete('chat_messages');
  }
}