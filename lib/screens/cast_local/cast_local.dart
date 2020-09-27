import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/film_class.dart';
import 'package:flutter/material.dart';

class CastLocalScreen extends StatefulWidget {
  @override
  _CastLocalScreenState createState() => _CastLocalScreenState();
}

class _CastLocalScreenState extends State<CastLocalScreen> {
  FilmClass _film;
  String _fullPath = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        final CastLocalArgument arg = ModalRoute.of(context).settings.arguments;
        _film = arg.film;
        _fullPath = arg.fullPath;
      });
    });
    print('${_film.toString()}$_fullPath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Film'),
      ),
    );
  }
}
