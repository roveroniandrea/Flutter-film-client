import 'dart:async';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';

/// Dialog utilizzato quando di attende il realod del server.
///
/// Mostra un CircularProgressIndicator con un conto alla rovescia all'interno
///
/// Il dialog non è dismissibile dall'utente ma va chiuso programmaticamente
class RestartingServerDialog extends StatefulWidget {
  @override
  _RestartingServerDialogState createState() => _RestartingServerDialogState();
}

class _RestartingServerDialogState extends State<RestartingServerDialog> {
  /// Intervallo di aggiornamento dello stato.
  /// Serve a evitare scatti del CircularProgressIndicator
  final double _secondsInterval = 0.01;

  /// Secondi rimanenti prima della chiusura del dialog.
  /// Non chiude effettivamente il dialog ma serve ad azzerare il CircularProgressIndicator
  double _secondsRemaining = FilmServerInterface.timeToRestart.inSeconds * 1.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Timer che ad ogni tot aggiorna lo stato del dialog
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
    // Cancello il timer
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Impedisco che il dilog possa essere chiuso premendo indietro
      canPop: false,
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
                      child: Text(
                        _secondsRemaining.ceil().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 40.0),
                      ),
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
            )
          ],
        ),
      ),
    );
  }
}
