import 'dart:async';

import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';

class RestartingServerDialog extends StatefulWidget {
  @override
  _RestartingServerDialogState createState() => _RestartingServerDialogState();
}

class _RestartingServerDialogState extends State<RestartingServerDialog> {
  double _secondsInterval = 0.01;
  double _secondsRemaining = FilmServerInterface.timeToRestart.inSeconds * 1.0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
        Duration(milliseconds: (_secondsInterval * 1000).round()), (timer) {
      setState(() {
        _secondsRemaining = FilmServerInterface.timeToRestart.inSeconds -
            timer.tick * _secondsInterval;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future<bool>.delayed(Duration.zero);
      },
      child: AlertDialog(
        title: new Text('Il film inizierà a breve',
            style: TextStyle(fontSize: 25.0)),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            new Text('Il server si sta riavviando, attendi...',
            style: TextStyle(fontSize: 20.0)),
        Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: SizedBox(
            child: Stack(
              fit: StackFit.expand,
              children: [
              Align(
              alignment: Alignment.center,
              child: Text(_secondsRemaining.ceil().toString(), textAlign: TextAlign.center, style: TextStyle(fontSize: 40.0),),
          ),
          CircularProgressIndicator(
            value: _secondsRemaining /
                FilmServerInterface.timeToRestart.inSeconds,
            strokeWidth: 7.0,
          ),
          ],
        ),
        height: 100.0,
        width: 100.0,
      ),
    )],
    )
    ,
    )
    ,
    );
  }
}
