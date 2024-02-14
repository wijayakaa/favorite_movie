  import 'package:favorite_movie/helper/database_helper.dart';
  import 'package:flutter/material.dart';
  import 'package:favorite_movie/controller/movie_controller.dart';
  import 'package:favorite_movie/model/movie_model.dart';
  import 'package:favorite_movie/favoritePage.dart';
  import 'package:favorite_movie/helper/database_helper.dart';

  class Homepage extends StatefulWidget {
    const Homepage({Key? key, required this.title}) : super(key: key);

    final String title;

    @override
    State<Homepage> createState() => _HomepageState();
  }

  class _HomepageState extends State<Homepage> {
    final MovieController _movieController = MovieController();
    final dbHelper = DatabaseHelper();
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          movies[index].title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(movies[index].year.toString()),
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movies[index].posterPath}',
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        onPressed: () {
                          _showConfirmationDialog(movies[index]);
                        },
                        child: Text(
                          "Add to Favorites",
                          style: TextStyle(color: Colors.amber[600]),
                        ),
                      ),
                    ],
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

    Future<void> _showConfirmationDialog(Movie movie) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add to Favorites'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Are you sure you want to add "${movie.title}" to favorites?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _addToFavorites(movie);
                },
              ),
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void _addToFavorites(Movie movie) async {
      print('Adding movie to favorites: ${movie.title}');
      int result = await dbHelper.insertMovie(movie);
      if (result != 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Added to Favorites')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to Add to Favorites')));
      }
    }
  }