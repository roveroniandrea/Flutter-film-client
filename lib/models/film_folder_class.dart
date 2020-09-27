import 'package:film_client/models/film_class.dart';

class FilmFolderClass{
  String path = '';
  List<FilmFolderClass> folders = [];
  List<FilmClass> films = [];

  FilmFolderClass({this.path, this.folders, this.films});

  factory FilmFolderClass.fromJson(Map<String, dynamic> json){
    return FilmFolderClass(
      path: json['path'],
      films: (json['films'] as List<dynamic>).map((film) => FilmClass(title: film as String)).toList(),
      folders: (json['folders'] as List<dynamic>).map((folder) => FilmFolderClass.fromJson(folder)).toList()
    );
  }
}