import 'package:film_server/models/film_class.dart';
import 'package:film_server/models/film_folder_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  final FilmFolderClass _films = FilmFolderClass(path: '', folders: [
    FilmFolderClass(path: 'Star Wars', films: [
      FilmClass(title: 'La minaccia fantasma.mp4'),
      FilmClass(title: 'L attacco dei cloni.m4v')
    ], folders: [])
  ], films: [
    FilmClass(title: 'Cary Grant.pdf')
  ]);

  final List<String> _path = [];

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lista dei film'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadFilms,
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20.0),
              child: BreadCrumb(
                items: (['Film'] + _path)
                    .asMap()
                    .entries
                    .map((entry) => BreadCrumbItem(
                        content:
                            Text(entry.value, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                        onTap: () => _handleBreacrumbTap(entry.key)))
                    .toList(),
                divider: Icon(Icons.chevron_right, color: Colors.orange),
                overflow: WrapOverflow(
                    direction: Axis.horizontal, keepLastDivider: false),
              ),
            ),
            _buildFilmList()
          ],
        ),
      ),
      onWillPop: _onBackPressed,
    );
  }

  Widget _buildFilmList() {
    FilmFolderClass subtree = _films;
    _path.forEach((p) => {
          if (subtree != null)
            {
              subtree = _films.folders
                  .firstWhere((folder) => folder.path == p, orElse: () => null)
            }
        });
    return ListView(
      padding: EdgeInsets.all(16.0),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      children: (subtree.folders.map<Widget>((folder) {
                return ListTile(
                  title: Text(folder.path),
                  leading: Icon(Icons.folder),
                  onTap: () => _handleFolderTap(folder),
                );
              }).toList() +
              subtree.films.map<Widget>((film) {
                return ListTile(
                  title: Text(film.title),
                  leading: Icon(Icons.movie,
                      color: film.isSupported() ? Colors.green : Colors.red),
                  onTap: () => _handleFilmTap(film),
                );
              }).toList())
          .expand((element) => [element, Divider()])
          .toList(),
    );
  }

  void _loadFilms() {
    //TODO: recuperare da server
    setState(() {
      _path.length = 0;
    });
  }

  Future<bool> _onBackPressed() {
    if (_path.length > 0) {
      setState(() {
        _path.removeLast();
      });
      return Future.value(false);
    } else {
      return showDialog<bool>(
          context: context,
          barrierDismissible: false,
          child: AlertDialog(
            title: Text("Vuoi uscire dall'app?"),
            actions: [
              FlatButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('Sì'),
                onPressed: () => Navigator.of(context).pop(true),
              )
            ],
          ));
    }
  }

  void _handleFilmTap(FilmClass film) {
    //TODO:
  }

  void _handleFolderTap(FilmFolderClass folder) {
    setState(() {
      _path.add(folder.path);
    });
  }

  void _handleBreacrumbTap(int pathLength) {
    if (_path.length != pathLength) {
      setState(() {
        _path.length = pathLength;
      });
    }
  }
}
