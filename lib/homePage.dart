import 'package:favorite_movie/controller/favorite_controller.dart';
import 'package:favorite_movie/helper/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:favorite_movie/controller/movie_controller.dart';
import 'package:favorite_movie/model/movie_model.dart';
import 'package:favorite_movie/favoritePage.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final MovieController _movieController = MovieController();
  final dbHelper = DatabaseHelper();
  final FavoritController _favoritController = FavoritController();

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber[600],
        title: Text('Movie App'),
      ),
      backgroundColor: Colors.black,
      body: _getBody(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.amber[600],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _getBody(int index) {
    switch (index) {
      case 0:
        return _buildMoviesList();
      case 1:
        return FavoritePage();
      default:
        return Container();
    }
  }

  Widget _buildMoviesList() {
    return FutureBuilder<List<Movie>>(
      future: _movieController.getMovies(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Movie> movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.all(10),
                color: Colors.amber,
                child: ListTile(
                  title: Text(
                    movies[index].title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Rate: ${movies[index].voteAverage.toStringAsFixed(1)}',
                  ),
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movies[index].posterPath}',
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.favorite_border),
                    onPressed: () {
                      _addToFavorites(movies[index], context);
                    },
                  ),
                  onTap: () {
                    // Tambahkan aksi ketika item ListTile ditekan jika diperlukan
                  },
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void _addToFavorites(Movie movie, BuildContext context) async {
    print('Adding movie to favorites: ${movie.title}');
    int result = await _favoritController.addToFavorites(movie);
    if (result != 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added to Favorites')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Add to Favorites')));
    }
  }
}
