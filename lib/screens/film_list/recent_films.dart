import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_folder_class.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:flutter/material.dart';

class RecentFilms extends StatelessWidget {
  final List<FilmFolderClass> _recentFilms;

  final BuildContext _context;

  RecentFilms(this._recentFilms, this._context);

  @override
  Widget build(BuildContext context) {
    return _recentFilms.length > 0 ? _buildList() : Container();
  }

  Widget _buildList() {
    return ListView(
        key: PageStorageKey<String>('list_recent'),
        padding: EdgeInsets.all(16.0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        controller: ScrollController(keepScrollOffset: true),
        physics: BouncingScrollPhysics(),
        children: _buildRecentFilmsTiles());
  }

  List<Widget> _buildRecentFilmsTiles() {
    return _recentFilms
        .map((f) {
          FilmClass film = f.films[0];
          return ListTile(
            title: Text(film.title),
            leading: Icon(Icons.movie, color: film.isSupported() ? Colors.green : Colors.red),
            onTap: () {
              String fullPath = "${f.path}/${film.title}";
              Navigator.pushNamed(_context, InspectFilmArgument.routeName, arguments: InspectFilmArgument(film: film, fullPath: fullPath));
            },
            visualDensity: VisualDensity.comfortable,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            subtitle: Text(film.humanDate),
          );
        })
        .expand((element) => [element, Divider()])
        .toList();
  }
}
