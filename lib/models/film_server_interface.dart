import 'dart:convert';
import 'package:film_client/models/shared_preferences_keys.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'film_folder_class.dart';
import 'package:http/http.dart' as http;

class FilmServerInterface {
  static String _ip = '192.168.1.8';
  static int _port = 9000;
  static String _entry = 'native';
  static bool _loaded = false;

  static final String _defaultIp = '192.168.1.8';
  static final int _defaultPort = 9000;

  static Future<String> get _url async {
    await _loadSettings();
    return 'http://$_ip:$_port/$_entry';
  }

  static Future<FilmFolderClass> getFilms() async {
    final url = await _url;
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return FilmFolderClass.fromJson(json.decode(response.body));
    } else {
      throw new Exception('Error getFilms ${response.reasonPhrase}');
    }
  }

  static Future<List<String>> getChromecasts() async {
    final url = await _url;
    final response = await http.get('$url/getDevices');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>).map((chr) {
        return chr as String;
      }).toList();
    } else {
      throw new Exception('Error getChromecasts ${response.reasonPhrase}');
    }
  }

  static Future<bool> castOnDevice(String chromecast, String fullPath) async {
    final url = await _url;
    final response =
        await http.get('$url/devicePlay?path=$fullPath&devName=$chromecast');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  static Future<FilmFolderClass> reloadFilmDirectory() async {
    final url = await _url;
    final response = await http.get('$url/realoadDir');
    if (response.statusCode == 200) {
      return FilmFolderClass.fromJson(json.decode(response.body));
    } else {
      throw new Exception('Error reloadFilmDirectory ${response.reasonPhrase}');
    }
  }

  static Future<List<String>> get ipServer async {
    await _loadSettings();
    return _ip.split('.');
  }

  static Future<int> get portServer async {
    await _loadSettings();
    return _port;
  }

  static Future<void> _loadSettings() async {
    if (!_loaded) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _ip = prefs.getString(SharedPreferencesKeys.SERVER_IP) ?? _defaultIp;
      _port = prefs.getInt(SharedPreferencesKeys.Server_PORT) ?? _defaultPort;
      if (prefs.getString(SharedPreferencesKeys.SERVER_IP) == null) {
        _saveSettings();
      }
      _loaded = true;
    }
    return Future.delayed(Duration.zero);
  }

  static void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesKeys.SERVER_IP, _ip);
    prefs.setInt(SharedPreferencesKeys.Server_PORT, _port);
  }

  static void changeIp(String ip) {
    _ip = ip;
    _saveSettings();
  }

  static void changePort(int port){
    _port = port;
    _saveSettings();
  }

  static Future<bool> checkForUpdates() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final url = await _url;
    final response = await http.get('$url/appVersion');
    if (response.statusCode == 200) {
      return int.parse(packageInfo.buildNumber) < json.decode(response.body);
    } else {
      throw new Exception('Error check version ${response.reasonPhrase}');
    }
  }

  static void openDownloadLink() async{
    final url = await _url;
    if (await canLaunch('$url/getApp')) {
      await launch('$url/getApp');
    } else {
      throw new Exception('Could not launch $url/getApp');
    }
  }
}
