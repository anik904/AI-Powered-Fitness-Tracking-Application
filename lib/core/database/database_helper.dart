import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../repository/model/workout_session.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fitness_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE goals (
  id $idType,
  exerciseType $textType,
  target $integerType,
  unit $textType
)
''');

    await db.execute('''
CREATE TABLE workouts (
  id $idType,
  exerciseType $textType,
  reps $integerType,
  timestamp $textType
)
''');
  }

  // Goals
  Future<void> saveGoal(String exerciseType, int target, String unit) async {
    final db = await instance.database;
    final maps = await db.query('goals', where: 'exerciseType = ?', whereArgs: [exerciseType]);

    if (maps.isNotEmpty) {
      await db.update(
        'goals',
        {'target': target, 'unit': unit},
        where: 'exerciseType = ?',
        whereArgs: [exerciseType],
      );
    } else {
      await db.insert('goals', {
        'exerciseType': exerciseType,
        'target': target,
        'unit': unit,
      });
    }
  }

  Future<Map<String, dynamic>?> getGoal(String exerciseType) async {
    final db = await instance.database;
    final maps = await db.query(
      'goals',
      where: 'exerciseType = ?',
      whereArgs: [exerciseType],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  // Workouts
  Future<int> insertWorkout(WorkoutSession session) async {
    final db = await instance.database;
    return await db.insert('workouts', session.toMap());
  }

  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 100}) async {
    final db = await instance.database;
    final maps = await db.query(
      'workouts',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => WorkoutSession.fromMap(map)).toList();
  }

  Future<List<WorkoutSession>> getWorkoutsForToday() async {
    final db = await instance.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final maps = await db.query(
      'workouts',
      where: 'timestamp >= ?',
      whereArgs: [todayStart],
    );

    return maps.map((map) => WorkoutSession.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
