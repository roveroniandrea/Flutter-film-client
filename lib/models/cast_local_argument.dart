import 'film_class.dart';

/// Parametri della rotta per guardare il film in locale
class CastLocalArgument {
  /// Nome della rotta per vedere il film
  static final String routeName = '/castLocal';

  /// Il film da vedere
  FilmClass film;

  /// Percorso completo del film (solo percorso cartelle)
  String fullPath = '';

  CastLocalArgument({this.film, this.fullPath});
}
