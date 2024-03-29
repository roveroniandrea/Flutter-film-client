import 'dart:async';
import 'dart:collection';

import 'package:animations/animations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:film_client/components/custom_progress.dart';
import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_folder_class.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:film_client/screens/film_list/recent_films.dart';
import 'package:film_client/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// Screen per visualizzare l'elenco dei film e sottocartelle
class FilmList extends StatefulWidget {
  @override
  _FilmListState createState() => _FilmListState();
}

class _FilmListState extends State<FilmList>
    with SingleTickerProviderStateMixin {
  /// Elenco dei film con le varie cartelle
  FilmFolderClass? _films;

  /// Percorso del breadcrumb
  final List<String> _path = [];

  /// Indica se l'animazione asse x della lista deve essere in avantio in indietro
  bool _isForward = true;

  /// true se sta chiedendo i film al server
  bool _loadingFilms = false;

  /// diverso da '' se c'è stato un errore nella richiesta dei film
  String _loadingError = '';

// Indica se mostrare il testo "Connettiti al wifi"
  bool _showConnectToWifi = false;

  /// Listener per il cambio di connessione
  late StreamSubscription<ConnectivityResult> _streamSubscription;

  /// Settato a [true] se l'utente non vuole aggiornare l'app
  bool _skipUpdate = false;

  /// Indica se sto attualmente cercando se ci sono aggiornamenti
  bool _alreadyCheckingForUpdates = false;

  /// Indica se sto effettuando la ricerca per nome dei film
  bool _isSearching = false;

  /// Stringa con il nome del film che sto cercando
  String _searchPattern = '';

  /// Lista dei film più recenti
  List<FilmFolderClass> _recentFilms = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    // L'unico orientamento ammesso è il portrait up
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Ascolto per cambi di connessione
    final Connectivity _connectivity = new Connectivity();
    _connectivity.checkConnectivity().then((initialConnectivity) {
      setState(() {
        _showConnectToWifi = initialConnectivity == ConnectivityResult.none;
      });

      _streamSubscription =
          _connectivity.onConnectivityChanged.listen((connectivityResult) {
        setState(() {
          _showConnectToWifi = connectivityResult == ConnectivityResult.none;
        });

        if (connectivityResult != ConnectivityResult.none) {
          _loadFilms(false);
        }
      });
    });

    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    // Cancello il listener al cambio di connessione
    _streamSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: TabBarView(
            controller: _tabController,
            children: [
              CustomProgress(
                  hasError: _showConnectToWifi || _loadingError != '',
                  loadingText: 'Recupero i film...',
                  isLoading: _loadingFilms,
                  errorChild: _buildErrorWidget(),
                  child: _buildFilmList()),
              RecentFilms(_recentFilms, context),
            ],
          ),
        ),
      ),
      canPop: false,
      onPopInvoked: _onBackPressed,
    );
  }

  /// Crea il widget per mostare i film in elenco
  Widget _buildFilmList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(top: 20.0, left: 16.0),
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
            divider: Icon(Icons.chevron_right,
                color: DynamicTheme.of(context)
                    ?.convertTheme()
                    .colorScheme
                    .primary),
            overflow: WrapOverflow(
                direction: Axis.horizontal, keepLastDivider: false),
          ),
        ),
        Expanded(
          child: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 300),
            reverse: !_isForward,
            transitionBuilder: (child, animation, secondaryAnimation) {
              return SharedAxisTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                transitionType: SharedAxisTransitionType.horizontal,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              );
            },
            child: ListView(
                key: PageStorageKey<String>('list${_path.length}'),
                padding: EdgeInsets.all(16.0),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                controller: ScrollController(keepScrollOffset: true),
                physics: BouncingScrollPhysics(),
                children: _buildListTiles()),
          ),
        )
      ],
    );
  }

  /// Chiede la lista dei film al server e controlla (se possibile) se c'è un aggioramento dell'app
  void _loadFilms(bool requestReload) {
    if (!_alreadyCheckingForUpdates && !_skipUpdate) {
      // Controllo anche se ci sono aggiornameti
      _checkForUpdates();
    }

    setState(() {
      _loadingFilms = true;
      _path.length = 0;
      _loadingError = '';
      _recentFilms = [];
    });

    // Chiamata al server per i film
    Future<FilmFolderClass> httpCall = requestReload
        ? FilmServerInterface.reloadFilmDirectory()
        : FilmServerInterface.getFilms();

    httpCall.then((films) {
      setState(() {
        _loadingFilms = false;
        _films = films;
        _loadingError = '';
      });

      //Chiamata al server per i film recenti
      FilmServerInterface.getRecentFilms().then((films) {
        setState(() {
          _recentFilms = films;
        });
      }, onError: (err) {
        setState(() {
          _recentFilms = [];
        });
      });
    }, onError: (err) {
      setState(() {
        _loadingFilms = false;
        _loadingError = err.toString();
      });
    });
  }

  /// Gestisce l'azione dell'utente di back button
  ///
  /// Ordine di azioni:
  ///
  /// 1- Esco dalla ricerca
  ///
  /// 2- Torno indietro di una cartella
  ///
  /// 3- Chiedo se voglio uscire dall'app
  void _onBackPressed(bool _) async {
    if (_isSearching) {
      // Prima possibilità esco dalla ricerca film
      setState(() {
        _isSearching = false;
      });
      return;
    }

    if (_tabController.index > 0) {
      // Seconda possibilità torno all'elenco dei film
      setState(() {
        _tabController.animateTo(0);
      });
      return;
    }

    if (_path.length > 0) {
      // Terza possibilità salgo di una cartella
      setState(() {
        _path.removeLast();
        _isForward = false;
      });
      return;
    } else {
      // Quarta possibilità chiedo se voglio uscire dall'app
      await showDialog<bool>(
              builder: (context) => AlertDialog(
                    title: Text("Vuoi uscire dall'app?"),
                    actions: [
                      TextButton.icon(
                        icon: Icon(Icons.exit_to_app),
                        label: Text(
                          'Sì',
                        ),
                        // If yes, exit the app
                        onPressed: () => SystemNavigator.pop(),
                      ),
                      TextButton(
                        child: Text('No'),
                        // Otherwise just close the modal
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
              context: context,
              barrierDismissible: false,
              // See https://stackoverflow.com/questions/52450907/flutter-showdialog-with-navigator-pop
              useRootNavigator: false)
          .then((value) => value ?? false);
    }
  }

  /// Gestisce il clic su un film
  void _handleFilmTap(FilmClass film) {
    final String fullPath = '${_path.join('/')}/${film.title}';
    // Nuova rotta ad InspectFilm
    Navigator.pushNamed(context, InspectFilmArgument.routeName,
        arguments: InspectFilmArgument(film: film, fullPath: fullPath));
  }

  /// Gestisce il clic su una cartella
  void _handleFolderTap(FilmFolderClass folder) {
    setState(() {
      _path.add(folder.path);
      _isForward = true;
    });
  }

  /// Gestisce il tap su un elemento del breadcrumb.
  /// [pathLength] è l'index dell'elemento cliccato (0- based)
  void _handleBreacrumbTap(int pathLength) {
    if (_path.length != pathLength) {
      setState(() {
        _isForward = pathLength > _path.length;
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
              _showConnectToWifi
                  ? 'Non sei connesso al Wi-Fi'
                  : 'Il server è spento',
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.only(top: 30.0),
              child: Icon(_showConnectToWifi ? Icons.wifi_off : Icons.cloud_off,
                  size: 100.0,
                  color: DynamicTheme.of(context)
                      ?.convertTheme()
                      .colorScheme
                      .error),
            )
          ],
        ));
  }

  /// Controlla se ci sono aggiornamenti disponibili
  ///
  /// Se è disponibile un aggiornamento chiede all'utente se vuole essere reindirizzato alla pagina web del browser
  void _checkForUpdates() async {
    _alreadyCheckingForUpdates = true;
    FilmServerInterface.checkForUpdates().then((updateAvailable) {
      if (updateAvailable) {
        Future<bool> updateDialog = showDialog<bool>(
                builder: (context) => AlertDialog(
                      title: Text(
                          "E' disponibile un nuovo aggiornamento dell'app. Vuoi scaricarlo?"),
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
                    ),
                context: context,
                barrierDismissible: false)
            .then((value) => value ?? false);

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

  /// Crea l'appBar con eventuale campo di input per cercare i film
  AppBar _buildAppBar() {
    TabBar tabBar = TabBar(
      controller: _tabController,
      indicatorWeight: 4,
      tabs: [
        Tab(
          child: Text("Elenco completo"),
        ),
        Tab(
          text: "Più recenti",
        )
      ],
    );
    if (!_isSearching) {
      return AppBar(
        title: Text('Lista dei film'),
        bottom: tabBar,
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
            onPressed: () =>
                Navigator.pushNamed(context, OptionsScreen.routeName),
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
              hintText: "Cerca un film", border: InputBorder.none),
          autofocus: true,
          style: TextStyle(fontSize: 20.0),
          onChanged: (value) {
            setState(() {
              _searchPattern = value;
            });
          },
        ),
        bottom: tabBar,
      );
    }
  }

  /// Crea i tiles per i film e le cartelle. Separa i tile da un Divider
  List<Widget> _buildListTiles() {
    FilmFolderClass? subtree = _films;
    _path.forEach((p) =>
        subtree = subtree?.folders.firstWhere((folder) => folder.path == p));

    final Iterable<Widget> groupedFolders = _mapFolders(subtree)
        .fold<SplayTreeMap<String, List<FilmFolderClass>>>(new SplayTreeMap(),
            (acc, element) {
          String firstLetter = element.path[0].toLowerCase();
          if (!acc.containsKey(firstLetter)) {
            acc[firstLetter] = [];
          }

          acc[firstLetter]?.add(element);

          return acc;
        })
        .entries
        .map<Widget>((entry) {
          return StickyHeader(
            header: Container(
                height: 50.0,
                alignment: Alignment.centerLeft,
                child: Text(entry.key.toUpperCase(),
                    style:
                        TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
                color: DynamicTheme.of(context)
                    ?.convertTheme()
                    .colorScheme
                    .background),
            content: Column(
                children: entry.value
                    .map((folder) => ListTile(
                          title: Text(folder.path),
                          leading: Icon(Icons.folder),
                          onTap: () => _handleFolderTap(folder),
                          visualDensity: VisualDensity.comfortable,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ))
                    .toList()),
          );
        });

    final Iterable<Widget> groupedFilms =
        _mapFilms(subtree).map<Widget>((film) {
      return ListTile(
        title: Text(film.title),
        leading: Icon(Icons.movie,
            color: film.isSupported() ? Colors.green : Colors.red),
        onTap: () => _handleFilmTap(film),
        visualDensity: VisualDensity.comfortable,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
    });

    final List<Widget> tiles = groupedFolders
        .followedBy(groupedFilms)
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
            _isSearching
                ? "Nessun film in questa cartella soddisfa la ricerca"
                : "Questa cartella è vuota",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ];
    }
  }

  /// Ritorna le sottocartelle da visulizzare nel caso stia effettuando una ricerca
  List<FilmFolderClass> _mapFolders(FilmFolderClass? subtree) {
    if (_isSearching && _searchPattern != '') {
      return subtree?.folders
              .where((folder) => folder.matchesPattern(_searchPattern))
              .toList() ??
          [];
    } else {
      return subtree?.folders ?? [];
    }
  }

  /// Ritorna i film da visulizzare nel caso stia effettuando una ricerca
  List<FilmClass> _mapFilms(FilmFolderClass? subtree) {
    if (_isSearching && _searchPattern != '') {
      return subtree?.films
              .where((film) => film.matchesPattern(_searchPattern))
              .toList() ??
          [];
    } else {
      return subtree?.films ?? [];
    }
  }
}
