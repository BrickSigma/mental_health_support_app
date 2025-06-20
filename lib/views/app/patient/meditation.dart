import 'package:flutter/material.dart';
import 'package:mental_health_support_app/controllers/soundtrack_controller.dart';
import 'package:provider/provider.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SoundtrackController>(
      builder:
          (context, controller, child) => Scaffold(
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
                      child: PlayerContainer(controller.soundtracks[index]),
                    ),
                itemCount: controller.soundtracks.length,
              ),
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
