import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'tic_tac_toe.db';
  static const _databaseVersion = 1;

  static const tableScores = 'scores';
  static get columnId => 'id';
  static const columnPlayer1Score = 'player1_score';
  static get columnPlayer2Score => 'player2_score';
  static get columnTotalGames => 'total_games';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableScores (
        $columnId INTEGER PRIMARY KEY,
        $columnPlayer1Score INTEGER,
        $columnPlayer2Score INTEGER,
        $columnTotalGames INTEGER
      )
    ''');
  }

  Future<Map<String, dynamic>?> getScores() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> scores =
    await db.query(tableScores, limit: 1);
    if (scores.isNotEmpty) {
      return scores.first;
    } else {
      return null;
    }
  }

  Future<void> resetScores() async {
    Database db = await instance.database;
    await db.delete(tableScores);
  }

  Future<void> updateScores(bool player1Won) async {
    Database db = await instance.database;
    Map<String, dynamic>? scores = await getScores();
    if (scores == null) {
      await db.insert(tableScores, {
        columnPlayer1Score: player1Won ? 1 : 0,
        columnPlayer2Score: player1Won ? 0 : 1,
        columnTotalGames: 1
      });
    } else {
      int player1Score = scores[columnPlayer1Score] + (player1Won ? 1 : 0);
      int player2Score = scores[columnPlayer2Score] + (player1Won ? 0 : 1);
      int totalGames = scores[columnTotalGames] + 1;
      await db.update(tableScores, {
        columnPlayer1Score: player1Score,
        columnPlayer2Score: player2Score,
        columnTotalGames: totalGames
      });
    }
  }
}
