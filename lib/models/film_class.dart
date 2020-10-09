class FilmClass {
  static final _supportedFormats = ['.mp4', '.m4v'];

  String _title = '';
  String get title => _title;
  String _humanTitle = '';
  String get humanTitle => _humanTitle;
  String _format = '';


  FilmClass({String title}) {
    _title = title;
    final latestDot = title.lastIndexOf('.');
    if (latestDot > -1) {
      _format = title.substring(latestDot);
      _humanTitle = title.substring(0, latestDot);
    } else {
      _humanTitle = title;
    }
  }

  bool isSupported() {
    return _format != '' &&
        _supportedFormats.contains(_format) &&
        !title.contains("'");
  }

  String getFormat() {
    return _format;
  }

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

  bool matchesPattern(String pattern){
    return _title.contains(pattern);
  }
}
