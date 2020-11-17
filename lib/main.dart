import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Main dell'app. Carica le impostazioni e poi crea l'app
Future<void> main() async {
  // Necassario prima di accedere ai plugin
  WidgetsFlutterBinding.ensureInitialized();
  // Carico impostazioni
  await DynamicTheme.loadThemeAndBrightness();
  await FilmServerInterface.loadSettings();
  await initializeDateFormatting();
  //Finchè non chiamo l'app viene mostrato lo splash screen
  runApp(MyApp());
}

/// Root dell'app
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme();
  }
}
