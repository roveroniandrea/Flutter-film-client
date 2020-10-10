import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DynamicTheme.loadThemeAndBrightness();
  await FilmServerInterface.loadSettings();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme();
  }
}
