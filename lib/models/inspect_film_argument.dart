import 'package:film_client/models/film_class.dart';

/// Parametri della rotta per visualizzare un film
class InspectFilmArgument {
  /// Nome della rotta
  static final String routeName = '/inspect';

  /// Film da ispezionare
  late FilmClass _film;

  /// Film da ispezionare
  FilmClass get film => _film;

  /// Percorso completo del film dalla cartella radice
  String _fullPath = '';

  /// Percorso completo del film dalla cartella radice
  String get fullPath => _fullPath;

  InspectFilmArgument({required FilmClass film, String fullPath = ''}) {
    _film = film;
    _fullPath = fullPath;
  }
}
