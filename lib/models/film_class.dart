class FilmClass{
  final _supportedFormats = ['.mp4', '.m4v'];

  String title = '';
  String _format = '';

  FilmClass({this.title}){
    final latestDot = title.lastIndexOf('.');
    if(latestDot > -1){
      _format = title.substring(latestDot);
    }
  }

  bool isSupported(){
    return _format != '' && _supportedFormats.contains(_format);
  }

  String getFormat(){
    return _format;
  }
}