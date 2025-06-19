import 'package:flutter/material.dart';
import 'package:mental_health_support_app/controllers/soundtrack_controller.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  List<Soundtrack> players = [
    Soundtrack("Wind", "soundtracks/wind.mp3"),
    Soundtrack("Sea", "soundtracks/sea.mp3"),
    Soundtrack("Forest", "soundtracks/forest.mp3"),
    Soundtrack("Midnight", "soundtracks/midnight.mp3"),
    Soundtrack("Fireplace", "soundtracks/fireplace.mp3"),
    Soundtrack("Coffee Shop", "soundtracks/coffee_shop.mp3"),
  ];

  Future<void> loadPlayers() async {
    for (Soundtrack track in players) {
      await track.loadPlayer();
    }
  }

  @override
  void initState() {
    super.initState();

    loadPlayers().then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meditation Soundtracks"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: ListView.builder(
          itemBuilder:
              (context, index) => Padding(
                padding: const EdgeInsets.fromLTRB(0, 6, 0, 6),
                child: PlayerContainer(players[index]),
              ),
          itemCount: players.length,
        ),
      ),
    );
  }
}

class PlayerContainer extends StatefulWidget {
  const PlayerContainer(this.track, {super.key});

  final Soundtrack track;

  @override
  State<PlayerContainer> createState() => _PlayerContainerState();
}

class _PlayerContainerState extends State<PlayerContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
        child: ListenableBuilder(
          listenable: widget.track,
          builder:
              (context, child) => Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: widget.track.togglePlayer,
                        child: Icon(
                          widget.track.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(widget.track.title),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.volume_up),
                      Expanded(
                        child: Slider(
                          value: widget.track.volume,
                          onChanged: (value) => widget.track.setVolume(value),
                          min: 0,
                          max: 1,
                          divisions: 100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
