import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:film_client/screens/cast_local/cast_local.dart';
import 'package:film_client/screens/film_list/film_list.dart';
import 'package:film_client/screens/inspect_film/inspect_film.dart';
import 'package:film_client/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Client',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => FilmList(),
        InspectFilmArgument.routeName: (context) => InspectFilm(),
        OptionsScreen.routeName: (context) => OptionsScreen(),
        CastLocalArgument.routeName: (context) => CastLocalScreen()
      },
    );
  }
}
