import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/inspect_film_argument.dart';
import 'package:film_client/models/shared_preferences_keys.dart';
import 'package:film_client/screens/cast_local/cast_local.dart';
import 'package:film_client/screens/film_list/film_list.dart';
import 'package:film_client/screens/inspect_film/inspect_film.dart';
import 'package:film_client/screens/option_screen/options_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicThemeData {
  final Color primaryColor;
  final Color accentColor;

  DynamicThemeData(this.primaryColor, this.accentColor);
}

class DynamicTheme extends StatefulWidget {
  static int currentThemeIndex;
  static bool isLightTheme;

  @override
  _DynamicThemeState createState() => _DynamicThemeState();

  static _DynamicThemeState of(BuildContext context) {
    return context.findAncestorStateOfType<_DynamicThemeState>();
  }

  static Future<void> loadTheme() async {
    await Future.delayed(Duration(seconds: 1));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentThemeIndex = prefs.getInt(SharedPreferencesKeys.THEME_INDEX) ?? 7;
    isLightTheme = prefs.getBool(SharedPreferencesKeys.THEME_BRIGHTNESS) ?? true;
  }

  static void saveTheme(int index) async {
    currentThemeIndex = index;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(SharedPreferencesKeys.THEME_INDEX, index);
  }

  static void saveBrightness(bool isLight) async{
    isLightTheme = isLight;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SharedPreferencesKeys.THEME_BRIGHTNESS, isLight);
  }
}

class _DynamicThemeState extends State<DynamicTheme> {
  List<DynamicThemeData> dynamicThemes = [];

  _DynamicThemeState() {
    for (int i = 0; i < 16; i++) {
      dynamicThemes
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

  ThemeData convertTheme() {
    DynamicThemeData theme = dynamicThemes[DynamicTheme.currentThemeIndex];
    return ThemeData(
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        brightness: DynamicTheme.isLightTheme ? Brightness.light : Brightness
            .dark
    );
  }

  void setTheme(int themeIndex) {
    setState(() {
      DynamicTheme.saveTheme(themeIndex);
    });
  }

  void setBrightness(bool isLight){
    setState(() {
      DynamicTheme.saveBrightness(isLight);
    });
  }
}
