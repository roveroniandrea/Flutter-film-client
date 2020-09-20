import 'package:film_server/models/film_class.dart';

class InspectFilmArgument {
  static final String routeName = '/inspect';
  FilmClass film;
  String fullPath = '';

  InspectFilmArgument({this.film, this.fullPath});
}
