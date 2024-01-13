import 'package:film_client/models/film_class.dart';

/// Definisce una cartella contente film e altre sottocartelle
///
/// Nota che l'elemento radice è sempre di tipo [FilmFolderClass]
class FilmFolderClass {
  /// Percorso relativo del film (solo nome della cartella che lo contiene)
  String _path = '';

  /// Percorso relativo del film (solo nome della cartella che lo contiene)
  String get path => _path;

  /// Lista di tutte le sottocartelle
  List<FilmFolderClass> _folders = [];

  /// Lista di tutte le sottocartelle
  List<FilmFolderClass> get folders => _folders;

  ///Lista di tutti i film nella cartella
  List<FilmClass> _films = [];

  ///Lista di tutti i film nella cartella
  List<FilmClass> get films => _films;

  FilmFolderClass({required String path, required List<FilmFolderClass> folders, required List<FilmClass> films}) {
    _path = path;
    _folders = folders;
    _films = films;
  }

  /// Ritorna un'instanza di [FilmFolderClass] data una stringa json decodificata in [Map]
  ///
  /// Decodifica ricorsivamente tutte le sottocartelle e film
  factory FilmFolderClass.fromJson(Map<String, dynamic> json) {
    return FilmFolderClass(
        path: json['path'],
        films: (json['films'] as List<dynamic>).map((film) => FilmClass(title: film as String)).toList(),
        folders: (json['folders'] as List<dynamic>).map((folder) => FilmFolderClass.fromJson(folder)).toList());
  }

  /// Ritorna [true] se il [pattern] matcha un film o una sottocartella ricorsivamente
  ///
  /// Nota che il nome della cartella non influenza la ricerca
  bool matchesPattern(String pattern) {
    return _films.any((film) => film.matchesPattern(pattern)) || _folders.any((folder) => folder.matchesPattern(pattern));
  }
}
