import 'package:film_server/components/custom_progress.dart';
import 'package:film_server/models/cast_local_argument.dart';
import 'package:film_server/models/film_class.dart';
import 'package:film_server/models/inspect_film_argument.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InspectFilm extends StatefulWidget {
  @override
  _InspectFilmState createState() => _InspectFilmState();
}

class _InspectFilmState extends State<InspectFilm> {
  final List<String> _chromecasts = [];
  FilmClass _film;
  String _fullPath = '';
  bool _transmittingOnChromecast = false;
  bool _searchingChromecasts = false;
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        final InspectFilmArgument arg =
            ModalRoute.of(context).settings.arguments;
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
        title: Text('Trasmetti film'),
      ),
      body: Builder(
        builder: (context) {
          _scaffoldContext = context;
          return _buildBody();
        },
      ),
    );
  }

  Widget _buildBody() {
    final List<Widget> columnChildren = _film != null
        ? [
            Container(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Dove vuoi guardare\n"${_film.humanTitle}"?',
                style: TextStyle(fontSize: 25.0),
                textAlign: TextAlign.center,
              ),
            ),
            Divider()
          ]
        : [];
    if (_film != null) {
      columnChildren.add(_buildButtons());
    }
    return Column(children: columnChildren);
  }

  Widget _buildButtons() {
    final List<Widget> castLocal = _film.isSupported()
        ? [
            Container(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
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
                loadingText: _transmittingOnChromecast
                    ? 'Trasmissione in corso...'
                    : 'Recupero i Chromecast...',
                hasError: !_film.isSupported(),
                child: Column(children: [
                  Column(
                    children: [
                      Container(
                          padding: EdgeInsets.all(20.0),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: _chromecasts
                                .map(
                                  (chromecast) => RaisedButton(
                                    child: Text(chromecast),
                                    onPressed: () => _handleCast(chromecast),
                                  ),
                                )
                                .toList(),
                          )),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Non vedi il Chromecast?',
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ),
                      RaisedButton(
                        child: Text(
                          'Trova dispositivi',
                        ),
                        onPressed: () => _loadChomecasts(),
                      )
                    ],
                  ),
                ]),
                errorChild: Container(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Text(
                    'Impossibile trasmettere il film:\n\n${_film.notSupportedReason()}',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ]);
  }

  void _loadChomecasts() {
    // TODO:
    setState(() {
      _searchingChromecasts = true;
      _chromecasts.length = 0;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _searchingChromecasts = false;
        _chromecasts.add('Soggiorno');
        _chromecasts.add('Camera');
      });
    });
  }

  void _handleGuardaSuTelefono() {
    Navigator.pushNamed(context, CastLocalArgument.routeName,
        arguments: CastLocalArgument(film: _film, fullPath: _fullPath));
  }

  void _handleCast(String chromecast) {
    setState(() {
      _transmittingOnChromecast = true;
    });
    //TODO
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _transmittingOnChromecast = false;
      });

      Scaffold.of(_scaffoldContext).showSnackBar(SnackBar(
          content: Container(
            child: Text(
              'Trasmissione avvenuta!',
              style: TextStyle(fontSize: 20.0),
            ),
            padding: EdgeInsets.all(8.0),
          ),
          duration: Duration(seconds: 3)));
    });
  }
}
