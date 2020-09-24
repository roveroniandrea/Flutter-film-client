import 'package:film_server/components/custom_progress.dart';
import 'package:film_server/models/film_class.dart';
import 'package:film_server/models/film_folder_class.dart';
import 'package:film_server/models/film_server.dart';
import 'package:film_server/models/inspect_film_argument.dart';
import 'package:film_server/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  FilmFolderClass _films = FilmFolderClass(path: '', folders: [
    FilmFolderClass(path: 'Star Wars', films: [
      FilmClass(title: 'La minaccia fantasma.mp4'),
      FilmClass(title: 'L attacco dei cloni.m4v')
    ], folders: [])
  ], films: [
    FilmClass(title: 'Cary Grant.pdf')
  ]);

  final List<String> _path = [];

  bool _loadingFilms = false;

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
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () =>
                    Navigator.pushNamed(context, OptionsScreen.routeName),
              )
            ],
          ),
          body: CustomProgress(
              hasError: false,
              loadingText: 'Recupero i film...',
              isLoading: _loadingFilms,
              child: _buildFilmList())),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(20.0),
          child: BreadCrumb(
            items: (['Film'] + _path)
                .asMap()
                .entries
                .map((entry) => BreadCrumbItem(
                    content: Text(entry.value,
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    onTap: () => _handleBreacrumbTap(entry.key)))
                .toList(),
            divider: Icon(Icons.chevron_right, color: Colors.orange),
            overflow: WrapOverflow(
                direction: Axis.horizontal, keepLastDivider: false),
          ),
        ),
        ListView(
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
                          color:
                              film.isSupported() ? Colors.green : Colors.red),
                      onTap: () => _handleFilmTap(film),
                    );
                  }).toList())
              .expand((element) => [element, Divider()])
              .toList(),
        ),
      ],
    );
  }

  void _loadFilms() {
    setState(() {
      _loadingFilms = true;
      _path.length = 0;
    });

    FilmServer.getFilms().then((films) {
      print(films);
      setState(() {
        _loadingFilms = false;
        _films = films;
      });
    }, onError: (err) {
      setState(() {
        _loadingFilms = false;
      });
      print('Errore: $err');
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
    final String fullPath = _path.join('/');
    Navigator.pushNamed(context, InspectFilmArgument.routeName,
        arguments: InspectFilmArgument(film: film, fullPath: fullPath));
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
