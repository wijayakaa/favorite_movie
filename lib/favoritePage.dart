import 'package:favorite_movie/controller/favorite_controller.dart';
import 'package:favorite_movie/helper/database_helper.dart';
import 'package:favorite_movie/model/movie_model.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final dbHelper = DatabaseHelper();

  List<Movie> favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    _getFavoriteMovies();
  }

  Future<void> _getFavoriteMovies() async {
    final movies = await dbHelper.getMoviesList();
    setState(() {
      favoriteMovies = movies;
    });
  }

  Future<void> _deleteFavoriteMovie(int? id) async {
    if (id != null) {
      final result = await dbHelper.deleteMovie(id);
      if (result != 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Deleted from Favorites')));
        _getFavoriteMovies();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Delete from Favorites')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid movie ID')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: Center(
        child: favoriteMovies != null && favoriteMovies.isNotEmpty
            ? ListView.builder(
                itemCount: favoriteMovies.length,
                itemBuilder: (context, index) {
                  final movie = favoriteMovies[index];
                  return ListTile(
                    title: Text(movie.title),
                    subtitle: Text(movie.overview),
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie.posterPath}',
                        fit: BoxFit.cover,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteFavoriteMovie(movie.id),
                    ),
                  );
                },
              )
            : Text(
                'No Favorites yet',
                style: TextStyle(color: Colors.black),
              ),
      ),
    );
  }
}
