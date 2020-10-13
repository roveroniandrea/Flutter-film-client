import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/dynamic_theme_data.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:film_client/models/shared_preferences_keys.dart';
import 'package:film_client/screens/cast_local/cast_local.dart';
import 'package:film_client/screens/film_list/film_list.dart';
import 'package:film_client/screens/inspect_film/inspect_film.dart';
import 'package:film_client/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ingloba [MaterialApp] con il tema dinamico
class DynamicTheme extends StatefulWidget {
  /// Index del tema corrente
  static int _currentThemeIndex;

  /// Index del tema corrente
  static get currentThemeIndex => _currentThemeIndex;

  /// Specifica se light mode o dark mode
  static bool _isLightTheme;

  /// Specifica se light mode o dark mode
  static get isLightTheme => _isLightTheme;

  @override
  _DynamicThemeState createState() => _DynamicThemeState();

  /// Ritorna l'istanza di [DynamicTheme]
  static _DynamicThemeState of(BuildContext context) {
    return context.findAncestorStateOfType<_DynamicThemeState>();
  }

  /// Chiamato al preload dell'app
  ///
  /// Carica il tema e la light/dark mode salvati con shared_preferences package.
  /// Di default imposta un ciano e la brightness del dispositivo
  ///
  static Future<void> loadThemeAndBrightness() async {
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentThemeIndex = prefs.getInt(SharedPreferencesKeys.THEME_INDEX) ?? 7;
    _isLightTheme = prefs.getBool(SharedPreferencesKeys.THEME_BRIGHTNESS) ??
        SchedulerBinding.instance.window.platformBrightness == Brightness.light;
  }

  /// Chiamato dal widget stesso
  ///
  /// Salva il tema corrente con shared_preferences
  ///
  /// Per cambiare il tema a runtime usare [DynamicTheme.of(context).setTheme()]
  static void saveTheme(int index) async {
    _currentThemeIndex = index;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SharedPreferencesKeys.THEME_INDEX, index);
  }

  /// Salva la light/dark mode con shared_preferences
  ///
  /// Per cambiare la modalità a runtime usare [DynamicTheme.of(context).setBrightness()]
  static void saveBrightness(bool isLight) async {
    _isLightTheme = isLight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SharedPreferencesKeys.THEME_BRIGHTNESS, isLight);
  }
}

class _DynamicThemeState extends State<DynamicTheme> {
  /// Lista di tutti i temi dell'app
  List<DynamicThemeData> _dynamicThemes = [];

  /// Lista di tutti i temi dell'app
  List<DynamicThemeData> get dynamicThemes => _dynamicThemes;

  _DynamicThemeState() {
    // Creo la lista dei temi
    _dynamicThemes.clear();
    for (int i = 0; i < 16; i++) {
      _dynamicThemes
          .add(DynamicThemeData(Colors.primaries[i], Colors.accents[i]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Film Client',
      theme: convertTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => FilmList(),
        InspectFilmArgument.routeName: (context) => InspectFilm(),
        OptionsScreen.routeName: (context) => OptionsScreen(),
        CastLocalArgument.routeName: (context) => CastLocalScreen()
      },
    );
  }

  /// Ritorna il tema material in base alle impostazioni correnti
  ThemeData convertTheme() {
    DynamicThemeData theme = dynamicThemes[DynamicTheme.currentThemeIndex];
    return ThemeData(
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        brightness:
            DynamicTheme.isLightTheme ? Brightness.light : Brightness.dark);
  }

  /// Salva in locale e visualizza un nuovo tema
  void setTheme(int themeIndex) {
    setState(() {
      DynamicTheme.saveTheme(themeIndex);
    });
  }

  /// Salva in locale e visualizza la nuova modalità
  void setBrightness(bool isLight) {
    setState(() {
      DynamicTheme.saveBrightness(isLight);
    });
  }
}
