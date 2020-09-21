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
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        final InspectFilmArgument arg =
            ModalRoute
                .of(context)
                .settings
                .arguments;
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
      columnChildren.addAll(_buildButtons());
    }
    return Column(children: columnChildren);
  }

  List<Widget> _buildButtons() {
    if (_film.isSupported()) {
      final List<Widget> castButtons = [
        Container(
          padding: EdgeInsets.all(20.0),
          child: RaisedButton(
            child: Text('Guarda sul telefono'),
            onPressed: _handleGuardaSuTelefono,
          ),
        ),
        Divider()
      ];
      castButtons.addAll(_buildChromecastButtons());
      return castButtons;
    } else {
      return [
        Container(
          padding: EdgeInsets.only(top: 100.0),
          child: Text(
            'Impossibile trasmettere il film:\n\n${_film.notSupportedReason()}',
            style: TextStyle(
                color: Colors.red, fontSize: 20.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        )
      ];
    }
  }

  void _loadChomecasts() {
    // TODO:
    setState(() {
      _chromecasts.length = 0;
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
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

  List<Widget> _buildChromecastButtons() {
    return _chromecasts.length > 0 && !_transmittingOnChromecast
        ? [
      Container(
          padding: EdgeInsets.all(20.0),
          child: ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: _chromecasts
                .map(
                  (chromecast) =>
                  RaisedButton(
                    child: Text(chromecast),
                    onPressed: () => _handleCast(chromecast),
                  ),
            )
                .toList(),
          )),
      Container(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Non vedi il chromecast?',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      RaisedButton(
        child: Text(
          'Trova dispositivi',
        ),
        onPressed: () => _loadChomecasts(),
      )
    ]
        : [
      Container(
          child: Column(
            children: [
              Container(
                child: Text(
                    _transmittingOnChromecast
                        ? 'Trasmissione in corso...'
                        : 'Recupero i chromecast...',
                    style: TextStyle(fontSize: 20.0)),
                padding: EdgeInsets.all(30.0),
              ),
              SizedBox(
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 7.0,
                ),
                height: 100.0,
                width: 100.0,
              ),
            ],
          )),
    ];
  }
}
