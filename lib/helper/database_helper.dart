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
  String colYear = 'year';
  String colOverview = 'overview';
  String colPosterPath = 'posterPath';

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

    var moviesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return moviesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $movieTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colYear INTEGER, $colOverview TEXT, $colPosterPath TEXT)');
  }

  Future<int> insertMovie(Movie movie) async {
    Database? db = await this.database;
    var result = await db!.insert(movieTable, movie.toMap());
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
          year: moviesMapList[i]['year'],
          overview: moviesMapList[i]['overview'],
          posterPath: moviesMapList[i]['posterPath'],
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
      var result = await db!.rawQuery('SELECT COUNT(*) FROM $movieTable WHERE $colId = $id');
      int count = Sqflite.firstIntValue(result)!;
      return count > 0;
    } catch (e) {
      print("Error checking favorite movie: $e");
      return false;
    }
  }
}