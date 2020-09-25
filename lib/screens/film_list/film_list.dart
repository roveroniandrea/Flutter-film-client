import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:film_server/components/custom_progress.dart';
import 'package:film_server/models/film_class.dart';
import 'package:film_server/models/film_folder_class.dart';
import 'package:film_server/models/film_server_interface.dart';
import 'package:film_server/models/inspect_film_argument.dart';
import 'package:film_server/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  /// Elenco dei film con le varie cartelle
  FilmFolderClass _films;

  /// Percorso del breadcrumb
  final List<String> _path = [];

  /// true se sta chiedendo i film al server
  bool _loadingFilms = false;

  /// diverso da '' se c'è stato un errore nella richiesta dei film
  String _loadingError = '';

  ConnectivityResult _connectivityResult = ConnectivityResult.wifi;
  StreamSubscription<ConnectivityResult> _streamSubscription;

  @override
  void initState() {
    super.initState();

    final Connectivity _connectivity = new Connectivity();
    _streamSubscription =
        _connectivity.onConnectivityChanged.listen((connectivityResult) {
      setState(() {
        _connectivityResult = connectivityResult;
      });
      if (_connectivityResult == ConnectivityResult.wifi) {
        _loadFilms(false);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
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
                onPressed: () => _loadFilms(true),
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () =>
                    Navigator.pushNamed(context, OptionsScreen.routeName),
              )
            ],
          ),
          body: CustomProgress(
              hasError: _connectivityResult != ConnectivityResult.wifi ||
                  _loadingError != '',
              loadingText: 'Recupero i film...',
              isLoading: _loadingFilms,
              errorChild: _buildErrorWidget(),
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
    if(subtree == null){
      subtree = new FilmFolderClass(path: '', folders: [], films: []);
    }
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

  /// Chiede la lista dei film al server
  void _loadFilms(bool requestReload) {
    setState(() {
      _loadingFilms = true;
      _path.length = 0;
      _loadingError = '';
    });
    Future<FilmFolderClass> httpCall = requestReload? FilmServerInterface.reloadFilmDirectory() : FilmServerInterface.getFilms();
    httpCall.then((films) {
      print(films);
      setState(() {
        _loadingFilms = false;
        _films = films;
        _loadingError = '';
      });
    }, onError: (err) {
      setState(() {
        _loadingFilms = false;
        _loadingError = err.toString();
      });
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
    final String fullPath = '${_path.join('/')}/${film.title}';
    Navigator.pushNamed(context, InspectFilmArgument.routeName,
        arguments: InspectFilmArgument(film: film, fullPath: fullPath));
  }

  void _handleFolderTap(FilmFolderClass folder) {
    setState(() {
      _path.add(folder.path);
    });
  }

  /// Gestisce il tap su un elemento del breadcrumb.
  /// @param pathLength index dell'elemento cliccato (0- based)
  void _handleBreacrumbTap(int pathLength) {
    if (_path.length != pathLength) {
      setState(() {
        _path.length = pathLength;
      });
    }
  }

  /// Crea il widget per l'errore di connessione
  Widget _buildErrorWidget() {
    return Container(
        padding: EdgeInsets.only(top: 100.0),
        child: Column(
          children: [
            Text(
              _connectivityResult != ConnectivityResult.wifi
                  ? 'Non sei connesso al Wi-Fi'
                  : 'Il server è spento o ha rifiutato la connessione',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(
                  _connectivityResult != ConnectivityResult.wifi
                      ? Icons.signal_wifi_off
                      : Icons.cloud_off,
                  size: 100.0),
            )
          ],
        ));
  }
}
