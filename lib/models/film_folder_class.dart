import 'package:film_server/models/film_class.dart';

class FilmFolderClass{
  String path = '';
  List<FilmFolderClass> folders = [];
  List<FilmClass> films = [];

  FilmFolderClass({this.path, this.folders, this.films});
}