import 'package:film_server/models/film_class.dart';
import 'package:film_server/models/inspect_film_argument.dart';
import 'package:flutter/material.dart';

class InspectFilm extends StatefulWidget {
  @override
  _InspectFilmState createState() => _InspectFilmState();
}

class _InspectFilmState extends State<InspectFilm> {
  final List<String> _chromecasts = [];
  FilmClass _film;
  String _fullPath = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final InspectFilmArgument arg = ModalRoute.of(context).settings.arguments;
      _film = arg.film;
      _fullPath = arg.fullPath;
      _loadChomecasts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trasmetti film'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final List<Widget> columnChildren = [
      Container(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'Dove vuoi guardare\n"${_film.humanTitle}"?',
          style: TextStyle(fontSize: 25.0),
          textAlign: TextAlign.center,
        ),
      ),
      Divider()
    ];
    columnChildren.addAll(_buildButtons());
    return Column(children: columnChildren);
  }

  List<Widget> _buildButtons() {
    return _film.isSupported()
        ? [
            Container(
              padding: EdgeInsets.all(20.0),
              child: RaisedButton(
                child: Text('Guarda sul telefono'),
                onPressed: _handleGuardaSuTelefono,
              ),
            ),
            Divider(),
            Container(
              padding: EdgeInsets.all(20.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.start,
                children: _chromecasts
                    .map((chromecast) => RaisedButton(
                          child: Text(chromecast),
                          onPressed: () => _handleCast(chromecast),
                        ))
                    .toList(),
              ),
            )
          ]
        : [
            Text(
              'Impossibile trasmettere il film. Motivo:\n${_film.notSupportedReason()}',
              style: TextStyle(color: Colors.red, fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
          ];
  }

  void _loadChomecasts() {
    // TODO:
    setState(() {
      _chromecasts.add('Soggiorno TODO');
    });
  }

  void _handleGuardaSuTelefono() {
    //TODO
  }

  void _handleCast(String chromecast) {}
}
