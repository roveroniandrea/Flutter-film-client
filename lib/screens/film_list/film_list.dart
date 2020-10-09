import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:film_client/components/custom_progress.dart';
import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_folder_class.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:film_client/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _skipUpdate = false;
  bool _alreadyCheckingForUpdates = false;

  bool _isSearching = false;
  String _searchPattern = '';

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final Connectivity _connectivity = new Connectivity();
    _streamSubscription = _connectivity.onConnectivityChanged.listen((connectivityResult) {
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
        appBar: _buildAppBar(),
        body: CustomProgress(
            hasError: _connectivityResult != ConnectivityResult.wifi || _loadingError != '',
            loadingText: 'Recupero i film...',
            isLoading: _loadingFilms,
            errorChild: _buildErrorWidget(),
            child: _buildFilmList()),
      ),
      onWillPop: _onBackPressed,
    );
  }

  Widget _buildFilmList() {
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
                    content: Text(entry.value, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                    onTap: () => _handleBreacrumbTap(entry.key)))
                .toList(),
            divider: Icon(Icons.chevron_right, color: DynamicTheme.of(context).convertTheme().primaryColor),
            overflow: WrapOverflow(direction: Axis.horizontal, keepLastDivider: false),
          ),
        ),
        Expanded(
          child: ListView(
              key: PageStorageKey<String>('list${_path.length}'),
              padding: EdgeInsets.all(16.0),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              controller: ScrollController(keepScrollOffset: true),
              physics: BouncingScrollPhysics(),
              children: _buildListTiles()),
        )
      ],
    );
  }

  /// Chiede la lista dei film al server
  Future<void> _loadFilms(bool requestReload) {
    if (!_alreadyCheckingForUpdates && !_skipUpdate) {
      _checkForUpdates();
    }

    setState(() {
      _loadingFilms = true;
      _path.length = 0;
      _loadingError = '';
    });
    Future<FilmFolderClass> httpCall = requestReload ? FilmServerInterface.reloadFilmDirectory() : FilmServerInterface.getFilms();
    httpCall.then((films) {
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

    return httpCall;
  }

  Future<bool> _onBackPressed() {
    if (_isSearching) {
      setState(() {
        _isSearching = false;
      });
      return Future.value(false);
    }

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
              TextButton.icon(
                icon: Icon(Icons.exit_to_app),
                label: Text('Sì',),
                onPressed: () => Navigator.of(context).pop(true),
              ),
              TextButton(
                child: Text('No'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ));
    }
  }

  void _handleFilmTap(FilmClass film) {
    final String fullPath = '${_path.join('/')}/${film.title}';
    Navigator.pushNamed(context, InspectFilmArgument.routeName, arguments: InspectFilmArgument(film: film, fullPath: fullPath));
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
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 100.0),
        child: Column(
          children: [
            Text(
              _connectivityResult != ConnectivityResult.wifi
                  ? 'Non sei connesso al Wi-Fi'
                  : 'Il server è spento o ha rifiutato la connessione',
              style: TextStyle(color: DynamicTheme.of(context).convertTheme().errorColor, fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(_connectivityResult != ConnectivityResult.wifi ? Icons.wifi_off : Icons.cloud_off, size: 100.0),
            )
          ],
        ));
  }

  void _checkForUpdates() async {
    _alreadyCheckingForUpdates = true;
    FilmServerInterface.checkForUpdates().then((updateAvailable) {
      if (updateAvailable) {
        Future<bool> updateDialog = showDialog<bool>(
            context: context,
            barrierDismissible: false,
            child: AlertDialog(
              title: Text("E' disponibile un nuovo aggiornamento dell'app. Vuoi scaricarlo?"),
              actions: [
                TextButton.icon(
                  icon: Icon(Icons.get_app),
                  label: Text('Sì'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ));

        updateDialog.then((updateYN) {
          _alreadyCheckingForUpdates = false;
          if (updateYN == true) {
            FilmServerInterface.openDownloadLink();
          } else {
            _skipUpdate = true;
          }
        });
      }
    }, onError: (err) => {});
  }

  AppBar _buildAppBar() {
    if (!_isSearching) {
      return AppBar(
        title: Text('Lista dei film'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: "Cerca un film",
            onPressed: () {
              setState(() {
                _isSearching = true;
                _searchPattern = '';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _loadFilms(true),
            tooltip: "Ricarica i film",
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, OptionsScreen.routeName),
            tooltip: "Vai alle opzioni",
          )
        ],
      );
    } else {
      return AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
            });
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: "Cerca un film",
            border: InputBorder.none,
          ),
          autofocus: true,
          style: TextStyle(fontSize: 20.0),
          onChanged: (value) {
            setState(() {
              _searchPattern = value;
            });
          },
        ),
      );
    }
  }

  List<Widget> _buildListTiles() {
    FilmFolderClass subtree = _films;
    _path.forEach((p) => {
          if (subtree != null) {subtree = subtree.folders.firstWhere((folder) => folder.path == p, orElse: () => null)}
        });
    if (subtree == null) {
      subtree = new FilmFolderClass(path: '', folders: [], films: []);
    }

    final tiles = _mapFolders(subtree)
        .map<Widget>((folder) {
          return ListTile(
            title: Text(folder.path),
            leading: Icon(Icons.folder),
            onTap: () => _handleFolderTap(folder),
            visualDensity: VisualDensity.comfortable,
          );
        })
        .followedBy(_mapFilms(subtree).map<Widget>((film) {
          return ListTile(
            title: Text(film.title),
            leading: Icon(Icons.movie, color: film.isSupported() ? Colors.green : Colors.red),
            onTap: () => _handleFilmTap(film),
            visualDensity: VisualDensity.comfortable,
          );
        }))
        .expand((element) => [element, Divider()])
        .toList();

    if (tiles.length > 0)
      return tiles;
    else {
      return [
        Container(
          padding: EdgeInsets.only(top: 50),
          alignment: Alignment.center,
          child: Text(
            _isSearching ? "Nessun film in questa cartella soddisfa la ricerca" : "Questa cartella è vuota",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ];
    }
  }

  List<FilmFolderClass> _mapFolders(FilmFolderClass subtree) {
    if (_isSearching && _searchPattern != '') {
      return subtree.folders.where((folder) => folder.matchesPattern(_searchPattern)).toList();
    } else {
      return subtree.folders;
    }
  }

  List<FilmClass> _mapFilms(FilmFolderClass subtree) {
    if (_isSearching && _searchPattern != '') {
      return subtree.films.where((film) => film.matchesPattern(_searchPattern)).toList();
    } else {
      return subtree.films;
    }
  }
}
