import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:just_audio/just_audio.dart';

part 'current_song_notifier.g.dart';

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  void updadeSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(Uri.parse(song.song_url),
        tag: MediaItem(
          id: song.id,
          title: song.song_name,
          album: song.artist,
          artUri: Uri.parse(song.thumbnail_url),
          
        ));
    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero);
        audioPlayer!.pause();
      }
    });
    _homeLocalRepository.uploadLocalSong(song);
    audioPlayer?.play();
    state = song;
  }

  void playPause() {
    if (audioPlayer!.playing) {
      audioPlayer?.pause();
    } else {
      audioPlayer?.play();
    }
  }

  String formatDuration(Duration? duration) {
    if (duration == null) return "0:00";
    
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = twoDigits(duration.inSeconds % 60); 
    
    return "$minutes:$seconds";
  }
}