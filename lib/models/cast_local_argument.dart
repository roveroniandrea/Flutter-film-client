import 'film_class.dart';

class CastLocalArgument{
  static final String routeName = '/castLocal';
  FilmClass film;
  String fullPath = '';

  CastLocalArgument({this.film, this.fullPath});
}