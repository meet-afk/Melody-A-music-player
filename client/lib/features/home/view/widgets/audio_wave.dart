import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class AudioWave extends StatefulWidget {
  final String path;
  const AudioWave({super.key, required this.path});

  @override
  State<AudioWave> createState() => _AudioWaveState();
}

class _AudioWaveState extends State<AudioWave> {
  final PlayerController playerController = PlayerController();

  @override
  void initState() {
    super.initState();
    initAudioPlayer();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  void initAudioPlayer() async {
    await playerController.preparePlayer(
      path: widget.path,
      shouldExtractWaveform: true,
    );
    playerController.setFinishMode(finishMode: FinishMode.pause);

    setState(() {});
  }


  Future<void> playAndPause() async {
    if (!playerController.playerState.isPlaying) {
      await playerController.startPlayer();
    } else if (!playerController.playerState.isPaused) {
      await playerController.pausePlayer();
    }
    playerController.onPlayerStateChanged.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: playAndPause,
          icon: Icon(
            playerController.playerState.isPlaying 
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline,
            size: 40,
          ),
        ),
        Expanded(
          child: AudioFileWaveforms(
            size: const Size(double.infinity, 100),
            playerController: playerController,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: Pallete.borderColor,
              liveWaveColor: Pallete.gradient4,
              spacing: 6,
              showSeekLine: false,

            ),
          ),
        ),
      ],
    );
  }
}
