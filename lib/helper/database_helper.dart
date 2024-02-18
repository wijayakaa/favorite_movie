import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:favorite_movie/model/movie_model.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  String movieTable = 'movie_table';
  String colId = 'id';
  String colTitle = 'title';
  String colOverview = 'overview';
  String colPosterPath = 'posterPath';
  String colVoteAverage = 'voteAverage';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper!;
  }

  Future<Database?> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'movies.db');

    var moviesDatabase = await openDatabase(path,
        version: 2, onCreate: _createDb, onUpgrade: _upgradeDb);
    return moviesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $movieTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$colTitle TEXT, $colOverview TEXT, $colPosterPath TEXT, '
        '$colVoteAverage REAL)');
  }

  void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      var tableInfo = await db.rawQuery('PRAGMA table_info($movieTable)');
      bool columnExists =
          tableInfo.any((column) => column['name'] == colVoteAverage);
      if (!columnExists) {
        await db
            .execute('ALTER TABLE $movieTable ADD COLUMN $colVoteAverage REAL');
      }
    }
  }

  Future<int> insertMovie(Movie movie) async {
    print('Inserting movie into database: ${movie.title}');
    Database? db = await this.database;
    var result = await db!.insert(movieTable, movie.toMap());
    print('Movie inserted successfully');
    return result;
  }

  Future<List<Map<String, dynamic>>> getMoviesMapList() async {
    Database? db = await this.database;
    var result = await db!.query(movieTable);
    return result;
  }

  Future<List<Movie>> getMoviesList() async {
    try {
      var moviesMapList = await getMoviesMapList();
      int count = moviesMapList.length;

      List<Movie> moviesList = [];
      for (int i = 0; i < count; i++) {
        moviesList.add(Movie(
          id: moviesMapList[i]['id'],
          title: moviesMapList[i]['title'],
          overview: moviesMapList[i]['overview'],
          posterPath: moviesMapList[i]['posterPath'],
          voteAverage: moviesMapList[i]['voteAverage'],
        ));
      }

      return moviesList;
    } catch (e) {
      print("Error in getting movies list: $e");
      return [];
    }
  }

  Future<int> deleteMovie(int id) async {
    try {
      if (id != null) {
        Database? db = await this.database;
        int result = await db!.delete(
          movieTable,
          where: '$colId = ?',
          whereArgs: [id],
        );
        return result;
      } else {
        throw Exception('Invalid movie ID');
      }
    } catch (e) {
      print("Error deleting movie: $e");
      return 0;
    }
  }

  Future<bool> isMovieFavorite(int id) async {
    try {
      Database? db = await this.database;
      var result = await db!
          .rawQuery('SELECT COUNT(*) FROM $movieTable WHERE $colId = $id');
      int count = Sqflite.firstIntValue(result)!;
      return count > 0;
    } catch (e) {
      print("Error checking favorite movie: $e");
      return false;
    }
  }
}
