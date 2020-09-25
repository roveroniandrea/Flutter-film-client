import 'dart:convert';
import 'film_folder_class.dart';
import 'package:http/http.dart' as http;

class FilmServerInterface {
  static String _ip = '192.168.1.7';
  static int _port = 9000;
  static String _entry = 'native';

  static String get _url {
    //TODO recupera impostazioni locali
    return 'http://$_ip:$_port/$_entry';
  }

  static Future<FilmFolderClass> getFilms() async {
    final response = await http.get(_url);
    if (response.statusCode == 200) {
      return FilmFolderClass.fromJson(json.decode(response.body));
    } else {
      throw new Exception('Error getFilms ${response.reasonPhrase}');
    }
  }

  static Future<List<String>> getChromecasts() async {
    final response = await http.get('$_url/getDevices');
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>).map((chr) {
        return chr as String;
      }).toList();
    } else {
      throw new Exception('Error getChromecasts ${response.reasonPhrase}');
    }
  }

  static Future<bool> castOnDevice(String chromecast, String fullPath) async {
    final response =
        await http.get('$_url/devicePlay?path=$fullPath&devName=$chromecast');
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
