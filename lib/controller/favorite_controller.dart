import 'package:favorite_movie/helper/database_helper.dart';
import 'package:favorite_movie/model/movie_model.dart';

class FavoritController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> addToFavorites(Movie movie) async {
    return await _databaseHelper.insertMovie(movie);
  }

  Future<List<Movie>> getFavoriteMovies() async {
    return await _databaseHelper.getMoviesList();
  }

  Future<int> deleteMovie(int id) async {
    return await _databaseHelper.deleteMovie(id);
  }
}
