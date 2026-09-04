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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
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
  timestamp $textType,
  clientId $textNullable
)
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE workouts ADD COLUMN clientId TEXT');
      } catch (_) {
        // Column may already exist in some dev states
      }
    }
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

  Future<List<Map<String, dynamic>>> getAllGoals() async {
    final db = await instance.database;
    return await db.query('goals');
  }

  // Workouts
  Future<int> insertWorkout(WorkoutSession session) async {
    final db = await instance.database;

    // Check if duplicate exists by clientId
    if (session.clientId.isNotEmpty) {
      final existingByClient = await db.query(
        'workouts',
        where: 'clientId = ?',
        whereArgs: [session.clientId],
      );
      if (existingByClient.isNotEmpty) {
        return existingByClient.first['id'] as int;
      }
    }

    // Check if duplicate exists by exerciseType, reps, and close timestamp (within 15s)
    final existingRows = await db.query(
      'workouts',
      where: 'exerciseType = ? AND reps = ?',
      whereArgs: [session.exerciseType.name, session.reps],
      orderBy: 'timestamp DESC',
      limit: 10,
    );

    for (final row in existingRows) {
      final existingTimeStr = row['timestamp'] as String;
      final existingTime = DateTime.tryParse(existingTimeStr);
      if (existingTime != null) {
        final diffSeconds = session.timestamp.toUtc().difference(existingTime.toUtc()).inSeconds.abs();
        if (diffSeconds <= 15) {
          // Already recorded, update clientId if missing
          final existingId = row['id'] as int;
          if (row['clientId'] == null && session.clientId.isNotEmpty) {
            await db.update(
              'workouts',
              {'clientId': session.clientId},
              where: 'id = ?',
              whereArgs: [existingId],
            );
          }
          return existingId;
        }
      }
    }

    return await db.insert('workouts', session.toMap());
  }

  Future<int> cleanupDuplicateWorkouts() async {
    final db = await instance.database;
    final rows = await db.query('workouts', orderBy: 'id ASC');
    if (rows.length <= 1) return 0;

    final kept = <Map<String, dynamic>>[];
    final duplicateIds = <int>[];

    for (final row in rows) {
      final id = row['id'] as int;
      final exerciseType = row['exerciseType'] as String;
      final reps = row['reps'] as int;
      final timestampStr = row['timestamp'] as String;
      final clientId = row['clientId'] as String?;
      final timestamp = DateTime.tryParse(timestampStr);

      bool isDuplicate = false;
      for (final existing in kept) {
        final existingExercise = existing['exerciseType'] as String;
        final existingReps = existing['reps'] as int;
        final existingTimestampStr = existing['timestamp'] as String;
        final existingClientId = existing['clientId'] as String?;
        final existingTimestamp = DateTime.tryParse(existingTimestampStr);

        // Case 1: Matching non-empty clientId
        if (clientId != null &&
            clientId.isNotEmpty &&
            existingClientId != null &&
            existingClientId.isNotEmpty &&
            clientId == existingClientId) {
          isDuplicate = true;
          break;
        }

        // Case 2: Same exercise, same reps, and timestamps within 15 seconds
        if (exerciseType == existingExercise && reps == existingReps) {
          if (timestampStr == existingTimestampStr) {
            isDuplicate = true;
            break;
          }
          if (timestamp != null && existingTimestamp != null) {
            final diff = timestamp.toUtc().difference(existingTimestamp.toUtc()).inSeconds.abs();
            if (diff <= 15) {
              isDuplicate = true;
              break;
            }
          }
        }
      }

      if (isDuplicate) {
        duplicateIds.add(id);
      } else {
        kept.add(row);
      }
    }

    if (duplicateIds.isNotEmpty) {
      final batch = db.batch();
      for (final id in duplicateIds) {
        batch.delete('workouts', where: 'id = ?', whereArgs: [id]);
      }
      await batch.commit(noResult: true);
    }

    return duplicateIds.length;
  }

  Future<List<WorkoutSession>> getAllWorkouts() async {
    await cleanupDuplicateWorkouts();
    final db = await instance.database;
    final maps = await db.query(
      'workouts',
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => WorkoutSession.fromMap(map)).toList();
  }

  Future<List<WorkoutSession>> getRecentWorkouts({int limit = 100}) async {
    await cleanupDuplicateWorkouts();
    final db = await instance.database;
    final maps = await db.query(
      'workouts',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) => WorkoutSession.fromMap(map)).toList();
  }

  Future<List<WorkoutSession>> getWorkoutsForToday() async {
    await cleanupDuplicateWorkouts();
    final db = await instance.database;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).toIso8601String();
    
    final maps = await db.query(
      'workouts',
      where: 'timestamp >= ?',
      whereArgs: [todayStart],
      orderBy: 'timestamp DESC',
    );

    return maps.map((map) => WorkoutSession.fromMap(map)).toList();
  }

  Future<void> bulkUpsertWorkouts(List<WorkoutSession> workouts) async {
    if (workouts.isEmpty) return;
    final db = await instance.database;

    await cleanupDuplicateWorkouts();
    final existingLocalWorkouts = await getAllWorkouts();
    final batch = db.batch();

    for (final workout in workouts) {
      bool alreadyExists = false;

      for (final existing in existingLocalWorkouts) {
        // 1. Compare by clientId if present
        if (workout.clientId.isNotEmpty &&
            existing.clientId.isNotEmpty &&
            workout.clientId == existing.clientId) {
          alreadyExists = true;
          break;
        }

        // 2. Compare by exerciseType, reps, and timestamp proximity (within 15s)
        if (workout.exerciseType == existing.exerciseType &&
            workout.reps == existing.reps) {
          final diff = workout.timestamp.toUtc().difference(existing.timestamp.toUtc()).inSeconds.abs();
          if (diff <= 15) {
            alreadyExists = true;
            if (workout.clientId.isNotEmpty && existing.id != null) {
              batch.update(
                'workouts',
                {'clientId': workout.clientId},
                where: 'id = ?',
                whereArgs: [existing.id],
              );
            }
            break;
          }
        }
      }

      if (!alreadyExists) {
        batch.insert('workouts', workout.toMap());
      }
    }

    await batch.commit(noResult: true);
    await cleanupDuplicateWorkouts();
  }

  Future<void> clearWorkouts({DateTime? since}) async {
    final db = await instance.database;
    if (since != null) {
      await db.delete('workouts', where: 'timestamp >= ?', whereArgs: [since.toIso8601String()]);
    } else {
      await db.delete('workouts');
    }
  }

  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('goals');
    await db.delete('workouts');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
