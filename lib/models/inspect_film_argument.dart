import 'package:film_client/models/film_class.dart';

class InspectFilmArgument {
  static final String routeName = '/inspect';
  FilmClass film;
  String fullPath = '';

  InspectFilmArgument({this.film, this.fullPath});
}
