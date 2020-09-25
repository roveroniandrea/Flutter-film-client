import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'film_class.dart';
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
    if (kDebugMode) {
      return Future.delayed(
          Duration(seconds: 1),
          () => FilmFolderClass(path: '', folders: [
                FilmFolderClass(path: 'Star Wars', films: [
                  FilmClass(title: 'La minaccia fantasma.mp4'),
                  FilmClass(title: 'L attacco dei cloni.m4v')
                ], folders: [])
              ], films: [
                FilmClass(title: 'Cary Grant.pdf')
              ]));
    } else {
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        return FilmFolderClass.fromJson(json.decode(response.body));
      } else {
        throw new Exception('Error getFilms ${response.reasonPhrase}');
      }
    }
  }

  static Future<List<String>> getChromecasts() async {
    if (kDebugMode && false) {
      return Future.delayed(
          Duration(seconds: 1), () => ['Camera', 'Soggiorno']);
    } else {
      final response = await http.get('$_url/getDevices');
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List<dynamic>).map((chr) {
          return chr as String;
        }).toList();
      } else {
        throw new Exception('Error getChromecasts ${response.reasonPhrase}');
      }
    }
  }
}
