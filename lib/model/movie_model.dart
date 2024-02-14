class Movie {
  final int? id;
  final String title;
  final int year;
  final String overview;
  final String posterPath;

  Movie({
    required this.title,
    required this.year,
    required this.overview,
    required this.posterPath, 
    required this.id,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'overview': overview,
      'posterPath': posterPath,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      year: map['year'],
      overview: map['overview'],
      posterPath: map['posterPath'],
    );
  }
}