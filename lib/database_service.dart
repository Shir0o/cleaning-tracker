import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart' show Task;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static bool testingMode = false;
  static Database? _mockDb;

  static void setMockDb(Database? mockDb) {
    _mockDb = mockDb;
  }

  Database? _db;

  Future<Database> get db async {
    if (_mockDb != null) return _mockDb!;
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    if (testingMode && _mockDb == null) {
      throw UnsupportedError('Database not available in testing mode');
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cleaning_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            interval TEXT,
            lastCompleted TEXT,
            category TEXT,
            notes TEXT,
            snoozedUntil TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE completions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task_id INTEGER,
            date TEXT,
            FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE tasks ADD COLUMN snoozedUntil TEXT');
        }
      },
    );
  }

  Future<void> migrateFromSharedPreferences() async {
    if (testingMode) return;
    final prefs = await SharedPreferences.getInstance();
    final isMigrated = prefs.getBool('migration_complete') ?? false;
    if (isMigrated) return;

    final taskStrings = prefs.getStringList('tasks') ?? [];
    for (var s in taskStrings) {
      final json = jsonDecode(s) as Map<String, dynamic>;
      final task = Task.fromJson(json);
      await insertTask(task);
    }

    await prefs.setBool('migration_complete', true);
  }

  Future<int> insertTask(Task task) async {
    if (testingMode) return 0;
    final database = await db;
    final id = await database.insert('tasks', {
      'title': task.title,
      'interval': task.interval,
      'lastCompleted': task.lastCompleted.toIso8601String(),
      'category': task.category,
      'notes': task.notes,
      'snoozedUntil': task.snoozedUntil?.toIso8601String(),
    });

    for (var completion in task.completions) {
      await database.insert('completions', {
        'task_id': id,
        'date': completion.toIso8601String(),
      });
    }
    return id;
  }

  Future<List<Task>> getTasks() async {
    if (testingMode) return [];
    final database = await db;
    final List<Map<String, dynamic>> taskMaps = await database.query('tasks');
    
    final List<Task> tasks = [];
    for (var map in taskMaps) {
      final taskId = map['id'] as int;
      final List<Map<String, dynamic>> completionMaps = await database.query(
        'completions',
        where: 'task_id = ?',
        whereArgs: [taskId],
        orderBy: 'date ASC',
      );
      
      final completions = completionMaps
          .map((m) => DateTime.parse(m['date'] as String))
          .toList();
          
      tasks.add(Task(
        id: taskId,
        title: map['title'] as String,
        interval: map['interval'] as String,
        lastCompleted: DateTime.parse(map['lastCompleted'] as String),
        category: map['category'] as String,
        notes: map['notes'] as String,
        completions: completions,
        snoozedUntil: map['snoozedUntil'] != null
            ? DateTime.parse(map['snoozedUntil'] as String)
            : null,
      ));
    }
    return tasks;
  }

  Future<void> updateTask(Task task) async {
    if (testingMode || task.id == null) return;
    final database = await db;
    await database.update(
      'tasks',
      {
        'title': task.title,
        'interval': task.interval,
        'lastCompleted': task.lastCompleted.toIso8601String(),
        'category': task.category,
        'notes': task.notes,
        'snoozedUntil': task.snoozedUntil?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
    
    // For simplicity in this migration, we'll sync completions by deleting and re-inserting
    // A better way would be to only insert new ones, but tasks usually don't have many.
    await database.delete('completions', where: 'task_id = ?', whereArgs: [task.id]);
    for (var completion in task.completions) {
      await database.insert('completions', {
        'task_id': task.id,
        'date': completion.toIso8601String(),
      });
    }
  }

  Future<void> deleteTask(int id) async {
    if (testingMode) return;
    final database = await db;
    await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
    // completions will be deleted via ON DELETE CASCADE if supported, but let's be explicit
    await database.delete('completions', where: 'task_id = ?', whereArgs: [id]);
  }

  Future<void> addCompletion(int taskId, DateTime date) async {
    if (testingMode) return;
    final database = await db;
    await database.insert('completions', {
      'task_id': taskId,
      'date': date.toIso8601String(),
    });
    await database.update(
      'tasks',
      {'lastCompleted': date.toIso8601String()},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Future<void> resetCategory(String category, DateTime date) async {
    if (testingMode && _mockDb == null) return;
    final database = await db;
    
    // Get all tasks in this category
    final List<Map<String, dynamic>> tasks = await database.query(
      'tasks',
      where: 'category = ?',
      whereArgs: [category],
    );

    await database.transaction((txn) async {
      for (var task in tasks) {
        final id = task['id'] as int;
        await txn.insert('completions', {
          'task_id': id,
          'date': date.toIso8601String(),
        });
        await txn.update(
          'tasks',
          {'lastCompleted': date.toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    });
  }

  Future<void> deleteAllTasks() async {
    if (testingMode) return;
    final database = await db;
    await database.transaction((txn) async {
      await txn.delete('completions');
      await txn.delete('tasks');
    });
  }
}
