import 'package:film_client/components/dynamic_theme.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';

/// Screen per settare le impostazioni del server
class OptionsScreen extends StatefulWidget {
  static final routeName = '/options';

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  /// Stile del titolo di ogni opzione
  final TextStyle _textStyle = TextStyle(fontSize: 20.0);

  /// Indirizzo ip del server espresso come array di 4 stringhe
  List<String> _serverIp = [];

  /// Numero di porta del server
  int _serverPort;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Opzioni')),
        body: SingleChildScrollView(
          child: Center(
              child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _serverIp.length > 0
                  ? [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Indirizzo IP del server: ', style: _textStyle),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${_serverIp[0]}.${_serverIp[1]}.', style: _textStyle),
                              Container(
                                  width: 50,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    style: _textStyle,
                                    textAlign: TextAlign.center,
                                    initialValue: _serverIp[2],
                                    onChanged: (value) => _changeIp(2, value),
                                  )),
                              Text('.', style: _textStyle),
                              Container(
                                width: 50,
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  style: _textStyle,
                                  textAlign: TextAlign.center,
                                  initialValue: _serverIp[3],
                                  onChanged: (value) => _changeIp(3, value),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Divider(),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Numero porta del server: ', style: _textStyle),
                          Container(
                              width: 100,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                style: _textStyle,
                                textAlign: TextAlign.center,
                                initialValue: '$_serverPort',
                                onChanged: (value) => _changePort(int.parse(value)),
                              )),
                        ],
                      ),
                      Divider(),
                      Text('Tema dell\'applicazione:', style: _textStyle),
                      Wrap(
                        children: _buildThemeSquares(),
                      ),
                      Divider(),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Modalità scura:', style: _textStyle),
                          Switch(
                            value: !DynamicTheme.isLightTheme,
                            onChanged: (ligth) => DynamicTheme.of(context).setBrightness(!ligth),
                          )
                        ],
                      )
                    ]
                  : [],
            ),
          )),
        ));
  }

  /// Carica le impostazioni dal locale
  void _loadSettings() {
    final ip = FilmServerInterface.ip;
    setState(() {
      _serverIp = ip;
    });

    final port = FilmServerInterface.port;
    setState(() {
      _serverPort = port;
    });
  }

  /// Salva un nuovo indirizzo ip del server
  void _changeIp(int ipPosition, String ipNumber) {
    _serverIp[ipPosition] = ipNumber;
    FilmServerInterface.changeIp(_serverIp.join('.'));
  }

  /// Cambia il numero di porta del server
  void _changePort(int port) {
    _serverPort = port;
    FilmServerInterface.changePort(_serverPort);
  }

  /// Crea i quadrati per cambiare il tema dell'app
  List<Widget> _buildThemeSquares() {
    List<Widget> res = [];
    final themes = DynamicTheme.of(context).dynamicThemes;
    for (int i = 0; i < themes.length; i++) {
      res.add(GestureDetector(
          onTap: () => DynamicTheme.of(context).setTheme(i),
          child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                    Container(
                      decoration: i == DynamicTheme.currentThemeIndex
                          ? BoxDecoration(border: Border.all(width: 3.0), color: themes[i].primaryColor)
                          : null,
                      margin: EdgeInsets.all(5.0),
                      height: 60.0,
                      width: 60.0,
                      color: i != DynamicTheme.currentThemeIndex ? themes[i].primaryColor : null,
                    ),
                  ] +
                  (i == DynamicTheme.currentThemeIndex ? [Icon(Icons.check)] : []))));
    }
    return res;
  }
}
