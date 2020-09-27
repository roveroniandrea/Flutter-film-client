import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';

class OptionsScreen extends StatefulWidget {
  static final routeName = '/options';

  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  final TextStyle _textStyle = TextStyle(fontSize: 20.0);

  List<String> _serverIp = [];
  int _serverPort;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opzioni'),
      ),
      body: Center(
          child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _serverIp.length > 0
              ? [
                  Text('Indirizzo IP del server: ', style: _textStyle),
                  Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${_serverIp[0]}.${_serverIp[1]}.',
                            style: _textStyle,
                          ),
                          Container(
                              width: 50,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                style: _textStyle,
                                textAlign: TextAlign.center,
                                initialValue: _serverIp[2],
                                onChanged: (value) => _changeIp(2, value),
                              )),
                          Text(
                            '.',
                            style: _textStyle,
                          ),
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
                  Row(
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
                ]
              : [],
        ),
      )),
    );
  }

  void _loadSettings() {
    FilmServerInterface.ipServer.then((ip) {
      setState(() {
        _serverIp = ip;
      });
    });

    FilmServerInterface.portServer.then((port) {
      setState(() {
        _serverPort = port;
      });
    });
  }

  void _changeIp(int ipPosition, String ipNumber){
    _serverIp[ipPosition] = ipNumber;
    FilmServerInterface.changeIp(_serverIp.join('.'));
  }

  void _changePort(int port){
    _serverPort = port;
    FilmServerInterface.changePort(_serverPort);
  }
}
