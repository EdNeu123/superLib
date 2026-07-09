import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/book.dart';

/// Armazenamento local dos livros favoritos, usando SQLite.
///
/// Funciona em Android/iOS (sqflite nativo) e em desktop — Windows, Linux
/// e macOS (via `sqflite_common_ffi`, necessário porque o plugin `sqflite`
/// puro só dá suporte a mobile). Web não é suportado nesta etapa.
class FavoritesDatabase {
  FavoritesDatabase._();

  static final FavoritesDatabase instance = FavoritesDatabase._();

  static const String _dbName = 'favoritos.db';
  static const String table = 'favorites';

  Database? _database;
  bool _factoryConfigured = false;

  void _configureFactoryIfNeeded() {
    if (_factoryConfigured) return;

    // Em Windows/Linux/macOS o sqflite precisa da implementação FFI.
    // Android e iOS já usam a implementação nativa do plugin sqflite.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    _factoryConfigured = true;
  }

  Future<Database> get database async {
    _configureFactoryIfNeeded();
    if (_database != null) return _database!;

    final dbDir = await getDatabasesPath();
    final path = p.join(dbDir, _dbName);

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $table (
            work_key TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            authors TEXT,
            cover_id INTEGER,
            first_publish_year INTEGER,
            edition_count INTEGER
          )
        ''');
      },
    );

    return _database!;
  }

  /// Retorna apenas as chaves (workKey) dos favoritos — usado pelas telas
  /// de listagem para saber rapidamente quais cards já estão marcados.
  Future<Set<String>> getFavoriteKeys() async {
    final db = await database;
    final rows = await db.query(table, columns: ['work_key']);
    return rows.map((r) => r['work_key'] as String).toSet();
  }

  /// Retorna os livros favoritos completos — usado na tela de favoritos.
  Future<List<Book>> getAllFavorites() async {
    final db = await database;
    final rows = await db.query(table, orderBy: 'title COLLATE NOCASE');
    return rows.map(Book.fromDbMap).toList();
  }

  Future<void> addFavorite(Book book) async {
    final db = await database;
    await db.insert(
      table,
      book.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String workKey) async {
    final db = await database;
    await db.delete(table, where: 'work_key = ?', whereArgs: [workKey]);
  }
}