import 'package:film_client/models/film_class.dart';

class InspectFilmArgument {
  static final String routeName = '/inspect';
  FilmClass _film;
  FilmClass get film => _film;
  String _fullPath = '';
  String get fullPath => _fullPath;

  InspectFilmArgument({FilmClass film, String fullPath}){
    _film = film;
    _fullPath = fullPath;
  }
}
