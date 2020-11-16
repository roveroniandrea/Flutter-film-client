import 'dart:convert';
import 'package:film_client/models/shared_preferences_keys.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'film_class.dart';
import 'film_folder_class.dart';
import 'package:http/http.dart' as http;

/// Esito di una trasmissione al Chromecast
enum CastResult { Done, Restarting, Error }

/// Interfaccia per comunicare con il server
class FilmServerInterface {
  /// Indirizzo ip del server
  static String _ip = '192.168.1.8';

  /// Indirizzo ip del server espresso come lista di 4 stringe.
  ///
  /// Esempio 192.168.1.8 diventa ['192','168','1','8']
  static List<String> get ip => _ip.split('.');

  /// Porta del server
  static int _port = 9000;

  /// Porta del server
  static int get port => _port;

  /// Primo pezzo di ogni url di richiesta al server
  static String _entry = 'native';

  /// Tempo impiegato al server per riavviarsi
  static final Duration timeToRestart = Duration(seconds: 7);

  /// Ritorna l'url iniziale per ogni chiamata al server
  static get _url {
    return 'http://$_ip:$_port/$_entry';
  }

  /// Ritorna la lista di tutti i film sul server
  ///
  /// In caso di errore ritorna una [Exception]
  static Future<FilmFolderClass> getFilms() async {
    final response = await http.get(_url).catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      return FilmFolderClass.fromJson(json.decode(response.body));
    } else {
      throw new Exception('Error getFilms ${response.reasonPhrase}');
    }
  }

  /// Ritorna l'elenco dei chromecast disponibili
  ///
  /// In caso di errore ritorna una [Exception]
  static Future<List<String>> getChromecasts() async {
    final response = await http.get('$_url/getDevices').catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List<dynamic>).map((chr) {
        return chr as String;
      }).toList();
    } else {
      throw new Exception('Error getChromecasts ${response.reasonPhrase}');
    }
  }

  /// Effettua il cast di un film su un chromecast
  ///
  /// Richiede [chromecast] il nome del dispositivo e [fullPath] il percorso del film a partire dalla cartella radice
  ///
  /// Ritorna l'esito della trasmissione con tipo [CastResult]
  static Future<CastResult> castOnDevice(String chromecast, String fullPath) async {
    final response = await http.get('$_url/devicePlay?path=$fullPath&devName=$chromecast').catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      return CastResult.Done;
    } else {
      if (response.statusCode == 503) {
        // Il server risponde con 503 a questa chiamata solo nel caso si stia per riavviare
        return CastResult.Restarting;
      } else {
        return CastResult.Error;
      }
    }
  }

  /// Richiede di ricaricare i film sul server e ritorna il nuovo elenco di film
  ///
  /// In caso di errore ritorna una [Exception]
  static Future<FilmFolderClass> reloadFilmDirectory() async {
    final response = await http.get('$_url/realoadDir').catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      return FilmFolderClass.fromJson(json.decode(response.body));
    } else {
      throw new Exception('Error reloadFilmDirectory ${response.reasonPhrase}');
    }
  }

  /// Chiamato nel preload dell'app per caricare le impostazioni di connessione al server con shared_preferences
  ///
  /// Imposta valori di default nel caso non ci siano opzioni salvate
  static Future<void> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _ip = prefs.getString(SharedPreferencesKeys.SERVER_IP) ?? '192.168.1.8';
    _port = prefs.getInt(SharedPreferencesKeys.Server_PORT) ?? 9000;
    if (prefs.getString(SharedPreferencesKeys.SERVER_IP) == null) {
      // Salvo i dati di default se necessario
      _saveSettings();
    }
  }

  /// Serve a salvare le nuove impostazioni con shared_preferences
  static void _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreferencesKeys.SERVER_IP, _ip);
    prefs.setInt(SharedPreferencesKeys.Server_PORT, _port);
  }

  /// Salva il nuovo indirizzo ip del server
  static void changeIp(String ip) {
    _ip = ip;
    _saveSettings();
  }

  /// Salva la nuova porta di connessione al server
  static void changePort(int port) {
    _port = port;
    _saveSettings();
  }

  /// Controlla se c'è una versione aggiornata dell'app
  ///
  /// Il confronto viene fatto tra il numero di build dell'app installata e quello ritornato dal server
  ///
  /// In caso di errore ritorna una [Exception]
  static Future<bool> checkForUpdates() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final response = await http.get('$_url/appVersion').catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      return int.parse(packageInfo.buildNumber) < json.decode(response.body);
    } else {
      throw new Exception('Error check version ${response.reasonPhrase}');
    }
  }

  /// Apre una finestra browser per scaricare la nuova versione dell'app
  ///
  /// In caso di errore ritorna una [Exception]
  static void openDownloadLink() async {
    if (await canLaunch('$_url/getApp')) {
      await launch('$_url/getApp');
    } else {
      throw new Exception('Could not launch $_url/getApp');
    }
  }

  /// Ritorna l'url completo di un film (compresa parte di http) dato il percorso completo dalla cartella radice
  ///
  /// Utilizzato da [CastLocalScreen]
  static String getFilmUrl(String fullPath) {
    if (fullPath.startsWith('/')) {
      fullPath = fullPath.replaceFirst('/', '');
    }

    final String encoded = Uri.encodeFull(fullPath);
    return 'http://$_ip:$_port/$encoded';
  }

  /// Ritorna la lista dei film più recenti
  static Future<List<FilmFolderClass>> getRecentFilms() async {
    final response = await http.get('$_url/recent').catchError((err) {
      return http.Response('', 404);
    });
    if (response.statusCode == 200) {
      List<dynamic> films = json.decode(response.body);
      return films.map((f) {
        return FilmFolderClass(
          path: f['path'],
          films: [FilmClass(title: f['name'])],
          folders: [],
        );
      }).toList();
    } else {
      throw new Exception('Error getFilms ${response.reasonPhrase}');
    }
  }
}
