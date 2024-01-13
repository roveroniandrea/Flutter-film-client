import 'package:film_client/components/custom_progress.dart';
import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/components/restarting_server_dialog.dart';
import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:flutter/material.dart';

/// Screen per ispezionare un film e scegliere dove guardarlo
class InspectFilm extends StatefulWidget {
  @override
  _InspectFilmState createState() => _InspectFilmState();
}

class _InspectFilmState extends State<InspectFilm> {
  /// Lista dei chromecast disponibili
  List<String> _chromecasts = [];

  /// Film da ispezionare
  FilmClass? _film;

  /// Percorso completo del film dalla cartella radice
  String _fullPath = '';

  /// Se [true] indica che sta chiedendo di tramettere ad un chromecast
  bool _transmittingOnChromecast = false;

  /// Se [false] indica che sta cercando i chromecast
  bool _searchingChromecasts = false;

  /// Context utilizzato per mostrare lo snackbar
  BuildContext? _scaffoldContext;

  @override
  void initState() {
    super.initState();
    // Non posso modificare lo stato direttamente in initState
    Future.delayed(Duration.zero, () {
      setState(() {
        final InspectFilmArgument arg = ModalRoute.of(context)?.settings.arguments as InspectFilmArgument;
        _film = arg.film;
        _fullPath = arg.fullPath;
      });
      _loadChomecasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trasmetti il film'),
      ),
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;
          return _buildBody();
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  /// Crea il body della pagina
  Widget _buildBody() {
    return _film != null
        ? Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Dove vuoi guardare\n"${_film?.humanTitle ?? ''}" ?',
                  style: TextStyle(fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              _buildButtons()
            ],
          )
        // Ritorno un widget vuoto per il primo frame perchè recupero gli argomenti della rotta
        : Column(
            children: [],
          );
  }

  /// Crea il pulsante per guardare il film in locale e quelli per i chromecast
  ///
  /// Gestisce anche gli stati di loading e film non supportato
  Widget _buildButtons() {
    final List<Widget> castLocal = (_film?.isSupported() ?? false)
        ? [
            Container(
              padding: EdgeInsets.all(20.0),
              child: ElevatedButton(
                child: Text('Guarda sul telefono'),
                onPressed: _handleGuardaSuTelefono,
              ),
            ),
            Divider()
          ]
        : [];

    return Column(
        children: castLocal +
            [
              CustomProgress(
                isLoading: _transmittingOnChromecast || _searchingChromecasts,
                loadingText: _transmittingOnChromecast ? 'Trasmissione in corso...' : 'Recupero i Chromecast...',
                hasError: !(_film?.isSupported() ?? false),
                child: Column(children: [
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20.0),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: _chromecasts
                                .map((chromecast) => ElevatedButton.icon(
                                      icon: Icon(Icons.cast),
                                      label: Text(chromecast),
                                      onPressed: () => _handleCast(chromecast),
                                    ))
                                .toList(),
                          )),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Non vedi il Chromecast?',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      ElevatedButton(
                        child: Text('Trova dispositivi'),
                        onPressed: () => _loadChomecasts(),
                      )
                    ],
                  ),
                ]),
                errorChild: Container(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Text(
                    'Impossibile trasmettere il film:\n\n${_film?.notSupportedReason() ?? ''}',
                    style:
                        TextStyle(color: DynamicTheme.of(context)?.convertTheme().colorScheme.error, fontSize: 20.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ]);
  }

  /// Carica i chromecast
  void _loadChomecasts() {
    setState(() {
      _searchingChromecasts = true;
      _chromecasts.length = 0;
    });

    FilmServerInterface.getChromecasts().then((chromecasts) {
      setState(() {
        _searchingChromecasts = false;
        _chromecasts = chromecasts;
      });
    }, onError: (err) {
      setState(() {
        _searchingChromecasts = false;
        _chromecasts = [];
      });
    });
  }

  /// Passa alla rotta per guardare il film sul telefono
  void _handleGuardaSuTelefono() {
    Navigator.pushNamed(context, CastLocalArgument.routeName, arguments: CastLocalArgument(film: _film as FilmClass, fullPath: _fullPath));
  }

  /// Inizia la trasmissione su un chromecast
  ///
  /// Gestisce anche il caso in cui il server risponda che si sta riavviando.
  /// In questo caso ripete la richiesto dopo il tempo di attesa
  void _handleCast(String chromecast) {
    setState(() {
      _transmittingOnChromecast = true;
    });

    FilmServerInterface.castOnDevice(chromecast, _fullPath).then((castResult) {
      setState(() {
        _transmittingOnChromecast = false;
      });
      // Se il server non è in fase di riavvio mostro lo snackbar
      if (castResult != CastResult.Restarting) {
        /*
        FIXME: Compile error
        Scaffold.of(_scaffoldContext as BuildContext).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Container(
              child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(castResult == CastResult.Done ? Icons.thumb_up : Icons.thumb_down,
                          color: castResult == CastResult.Done
                              ? DynamicTheme.of(context)?.convertTheme().iconTheme.color
                              : DynamicTheme.of(context)?.convertTheme().colorScheme.error)),
                  Text(
                    castResult == CastResult.Done ? 'Trasmissione avvenuta!' : 'Errore in trasmissione',
                    style: TextStyle(fontSize: 20.0),
                  ),
                ],
              ),
              padding: EdgeInsets.all(6.0),
            ),
            duration: Duration(seconds: 3)));

            */
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return RestartingServerDialog();
            });

        Future.delayed(FilmServerInterface.timeToRestart).then((_) {
          Navigator.of(context).pop(true);
          _handleCast(chromecast);
        });
      }
    });
  }
}
