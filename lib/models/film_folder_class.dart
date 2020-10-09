import 'package:film_client/models/film_class.dart';

class FilmFolderClass{
  String _path = '';
  String get path => _path;
  List<FilmFolderClass> _folders = [];
  List<FilmFolderClass> get folders => _folders;
  List<FilmClass> _films = [];
  List<FilmClass> get films => _films;

  FilmFolderClass({String path, List<FilmFolderClass> folders, List<FilmClass> films}){
    _path = path;
    _folders = folders;
    _films = films;
  }

  factory FilmFolderClass.fromJson(Map<String, dynamic> json){
    return FilmFolderClass(
      path: json['path'],
      films: (json['films'] as List<dynamic>).map((film) => FilmClass(title: film as String)).toList(),
      folders: (json['folders'] as List<dynamic>).map((folder) => FilmFolderClass.fromJson(folder)).toList()
    );
  }

  bool matchesPattern(String pattern){
    return _films.any((film) => film.matchesPattern(pattern)) || _folders.any((folder) => folder.matchesPattern(pattern));
  }
}