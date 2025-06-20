/// Soundtrack class used to handle different audio tracks.
library;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class Soundtrack extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  final String title;
  final String assetPath;
  bool isPlaying = false;
  double volume = 1;

  Soundtrack(this.title, this.assetPath);

  Future<void> loadPlayer() async {
    await player.setAsset(assetPath);
    await player.setLoopMode(LoopMode.one);
  }

  void togglePlayer() {
    if (isPlaying) {
      player.pause();
      isPlaying = false;
    } else {
      player.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  void setVolume(double value) {
    volume = value;
    player.setVolume(volume);
    notifyListeners();
  }
}
