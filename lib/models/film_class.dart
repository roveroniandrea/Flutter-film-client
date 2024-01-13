import 'package:intl/intl.dart';

/// Definisce un singolo film
class FilmClass {
  /// Formati supportati
  static final _supportedFormats = ['.mp4', '.m4v'];

  /// Titolo del film compresa l'estensione
  String _title = '';

  /// Titolo del film compresa l'estensione
  String get title => _title;

  /// Titolo del film esclusa l'estensione
  String _humanTitle = '';

  /// Titolo del film esclusa l'estensione
  String get humanTitle => _humanTitle;

  /// Estensione del film
  String _format = '';

  /// Data di creazione del film
  late DateTime dateTime;

  /// Ritorna una data leggibile
  String get humanDate {
    String lowercase = DateFormat("EEE", "it").format(dateTime) + " ${dateTime.day} " + DateFormat("MMMM", "it").format(dateTime);
    return "${lowercase[0].toUpperCase()}${lowercase.substring(1)}";
  }

  FilmClass({required String title, DateTime? dateTime}) {
    _title = title;
    this.dateTime = dateTime?? DateTime.now();
    final latestDot = title.lastIndexOf('.');
    if (latestDot > -1) {
      _format = title.substring(latestDot);
      _humanTitle = title.substring(0, latestDot);
    } else {
      _humanTitle = title;
    }
  }

  /// Ritorna [true] se l'estensione del film è tra quelle supportate
  bool isSupported() {
    return _format != '' && _supportedFormats.contains(_format) && !title.contains("'");
  }

  /// Ritorna il motivo per cui il film non è supportato
  String notSupportedReason() {
    if (!_supportedFormats.contains(_format)) {
      return 'Formato $_format non supportato';
    } else {
      if (title.contains("'")) {
        return 'Il titolo contiene un apostrofo';
      } else {
        return 'Errore sconosciuto';
      }
    }
  }

  /// Ritorna [true] se il pattern è presente all'interno del titolo del film
  ///
  /// La ricerca viene effettuata in lowercase per entrambe le stringhe e comprende anche l'estensione del film
  bool matchesPattern(String pattern) {
    return _title.toLowerCase().contains(pattern.toLowerCase());
  }
}
