import 'package:chewie/chewie.dart';
import 'package:film_client/components/custom_progress.dart';
import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Screen per guardare il film in locale
///
/// Il film inzierà una volta recuperato il film e impostato il corretto aspect ratio
class CastLocalScreen extends StatefulWidget {
  @override
  _CastLocalScreenState createState() => _CastLocalScreenState();
}

class _CastLocalScreenState extends State<CastLocalScreen> {
  /// Film da guardare. Recuperato dai parametri di rotta
  FilmClass? _film;

  /// Controller del video player
  VideoPlayerController? _controller;

  /// Se [true] indica che il ratio del film è stato caricato ed è possibile passarlo al video player
  bool _aspectRatioAvailable = false;

  @override
  void initState() {
    super.initState();

    // Ritardo l'esecuzione perchè non è possibile chiamare setState in modo sincrono su initState
    Future.delayed(Duration.zero, () {
      // Recupero i parametri di rotta
      final CastLocalArgument arg =
          ModalRoute.of(context)?.settings.arguments as CastLocalArgument;
      _film = arg.film;
      // Recupero l'url del server
      final filmUrlOnServer = FilmServerInterface.getFilmUrl(arg.fullPath);
      setState(() {
        // Imposto il controller
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(filmUrlOnServer));
        _controller?.initialize().then((value) {
          setState(() {
            // Quando il controller ha recuperato l'aspect ratio del film cambio lo stato
            _aspectRatioAvailable = true;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      // Elimino il controller
      _controller?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_film?.humanTitle ?? ''),
        ),
        body: CustomProgress(
          errorChild: Text('Errore non specificato'),
          hasError: false,
          isLoading: !_aspectRatioAvailable,
          loadingText: 'Connessione al server...',
          child: Chewie(
            controller: ChewieController(
                allowFullScreen: true,
                allowMuting: true,
                aspectRatio: _controller?.value.aspectRatio,
                autoInitialize: true,
                deviceOrientationsAfterFullScreen: [
                  DeviceOrientation.portraitUp
                ],
                fullScreenByDefault: false,
                looping: false,
                showControls: true,
                startAt: Duration.zero,
                autoPlay: true,
                draggableProgressBar: true,
                allowedScreenSleep: false,
                zoomAndPan: true,
                videoPlayerController: _controller as VideoPlayerController),
          ),
        ));
  }
}
