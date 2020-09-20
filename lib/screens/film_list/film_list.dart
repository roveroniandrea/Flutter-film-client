import 'package:film_server/models/film_class.dart';
import 'package:flutter/material.dart';

class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  final List<FilmClass> _films = [FilmClass('Prova.mp4', false), FilmClass('Sottocartella', true)];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista dei film'),
      ),
      body: _buildFilmList(),

    );
  }

  Widget _buildFilmList(){
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: _films.map<Widget>((film) {
        return ListTile(
          title: Text(film.title),
          leading: film.isFolder? Icon(Icons.folder): null,
        );
      }).toList(),
    );
  }
}
