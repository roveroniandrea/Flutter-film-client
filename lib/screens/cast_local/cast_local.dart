import 'package:chewie/chewie.dart';
import 'package:film_client/components/custom_progress.dart';
import 'package:film_client/models/cast_local_argument.dart';
import 'package:film_client/models/film_class.dart';
import 'package:film_client/models/film_server_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class CastLocalScreen extends StatefulWidget {
  @override
  _CastLocalScreenState createState() => _CastLocalScreenState();
}

class _CastLocalScreenState extends State<CastLocalScreen> {
  FilmClass _film;
  VideoPlayerController _controller;
  bool _aspectRatioAvailable = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        final CastLocalArgument arg = ModalRoute.of(context).settings.arguments;
        _film = arg.film;
        FilmServerInterface.getFilmUrl(arg.fullPath).then((filmUrlOnServer) {
          setState(() {
            _controller = VideoPlayerController.network(filmUrlOnServer);
            _controller.initialize().then((value) {
              setState(() {
                _aspectRatioAvailable = true;
              });
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_controller != null) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_film != null ? _film.humanTitle : ''),
      ),
      body: CustomProgress(
        errorChild: Text('Errore non specificato', style: TextStyle(color: Colors.red),),
        hasError: false,
        isLoading: !_aspectRatioAvailable,
        loadingText: 'Connessione al server...',
        child: Chewie(
          controller: ChewieController(
              allowFullScreen: true,
              allowMuting: true,
              aspectRatio: _controller.value.aspectRatio,
              autoInitialize: true,
              deviceOrientationsAfterFullScreen: [
                DeviceOrientation.portraitUp
              ],
              fullScreenByDefault: false,
              looping: false,
              showControls: true,
              startAt: Duration.zero,
              autoPlay: true,
              allowedScreenSleep: false,
              videoPlayerController: _controller),
        ),
      )
    );
  }
}
