/// Soundtrack class used to handle different audio tracks.
library;

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundtrackController extends ChangeNotifier {
  List<Soundtrack> soundtracks = [
    Soundtrack("Wind", "soundtracks/wind.mp3"),
    Soundtrack("Sea", "soundtracks/sea.mp3"),
    Soundtrack("Forest", "soundtracks/forest.mp3"),
    Soundtrack("Midnight", "soundtracks/midnight.mp3"),
    Soundtrack("Fireplace", "soundtracks/fireplace.mp3"),
    Soundtrack("Coffee Shop", "soundtracks/coffee_shop.mp3"),
  ];

  Future<void> loadPlayers() async {
    for (Soundtrack track in soundtracks) {
      await track.loadPlayer();
    }

    return;
  }
}

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
