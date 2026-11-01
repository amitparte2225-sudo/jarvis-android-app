import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance =
      DatabaseService._init();

  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('jarvis.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db, int version) async {
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER NOT NULL,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memory TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> createConversation(String title) async {
    final db = await database;

    return db.insert('conversations', {
      'title': title,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> saveMessage(
      int conversationId,
      String role,
      String content) async {
    final db = await database;

    return db.insert('messages', {
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>>
      getConversations() async {
    final db = await database;

    return db.query(
      'conversations',
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>>
      getMessages(int conversationId) async {
    final db = await database;

    return db.query(
      'messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
  }

  Future<int> saveMemory(String memory) async {
    final db = await database;

    return db.insert('memories', {
      'memory': memory,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>>
      getMemories() async {
    final db = await database;

    return db.query(
      'memories',
      orderBy: 'created_at DESC',
    );
  }

  Future<int> deleteMemory(int id) async {
    final db = await database;

    return db.delete(
      'memories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
