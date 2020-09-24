import 'dart:convert';

import 'film_folder_class.dart';
import 'package:http/http.dart' as http;

class FilmServer {
  static String _ip = '192.168.43.211';
  static int _port = 9000;
  static String _entry = 'native';

  static String get _url {
    //TODO recupera impostazioni locali
    return 'http://$_ip:$_port/$_entry';
  }

  static Future<FilmFolderClass> getFilms() async {
    throw new Exception('TODO');// TODO
    final response = await http.get(_url);
    print('whta');
    if(response.statusCode == 200){
      return FilmFolderClass.fromJson(json.decode(response.body));
    }
    else{
      throw new Exception('Error getFilms ${response.reasonPhrase}');
    }
  }
}
