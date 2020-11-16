import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_folder_class.dart';
import 'package:flutter/material.dart';

class RecentFilms extends StatelessWidget {
  final List<FilmFolderClass> _recentFilms;

  final Function(FilmClass) _onFilmTap;

  RecentFilms(this._recentFilms, this._onFilmTap);

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        controller: ScrollController(keepScrollOffset: true),
        physics: BouncingScrollPhysics(),
        children: _buildRecentFilmsTiles());
  }

  List<Widget> _buildRecentFilmsTiles() {
    return _recentFilms.length > 0
        ? _recentFilms.map((f) {
            FilmClass film = f.films[0];
            return ListTile(
              title: Text(film.title),
              leading: Icon(Icons.movie, color: film.isSupported() ? Colors.green : Colors.red),
              onTap: () => _onFilmTap(film),
              visualDensity: VisualDensity.comfortable,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            );
          }).expand((element) => [element, Divider()]).toList()
        : [];
  }
}
