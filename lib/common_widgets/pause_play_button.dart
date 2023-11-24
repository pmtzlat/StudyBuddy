import 'package:flutter/material.dart';

class PausePlayButton extends StatefulWidget {
  Function onPlay;
  Function onPause;
  PausePlayButton({super.key, required this.onPlay, required this.onPause});

  @override
  State<PausePlayButton> createState() => _PausePlayButtonState();
}

class _PausePlayButtonState extends State<PausePlayButton> {
  late bool play;

  @override
  void initState() {
    super.initState();
    play = true;
  }

  void changeToState(bool newState) {
    setState(() {
      play = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: play
            ? () {
                widget.onPlay();
                setState(() {
                  play = false;
                });
              }
            : () {
                widget.onPause();
                setState(() {
                  play = true;
                });
              },
        icon: play
            ? const Icon(Icons.play_arrow_rounded)
            : const Icon(Icons.pause_rounded));
  }
}
