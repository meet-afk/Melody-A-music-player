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
  List<SongModel> currentQueue = [];

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    
    // FIX: Initialize AudioPlayer exactly ONCE when the app starts.
    audioPlayer = AudioPlayer();

    // MAGIC: Just Audio natively triggers this stream whenever an automatic "Next Song" happens!
    audioPlayer!.currentIndexStream.listen((index) {
      if (index != null && index < currentQueue.length) {
        state = currentQueue[index];
        _homeLocalRepository.uploadLocalSong(currentQueue[index]);
      }
    });

    audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        audioPlayer!.seek(Duration.zero, index: 0);
        audioPlayer!.pause();
      }
    });

    return null;
  }

  void updadeSong(SongModel song, {List<SongModel>? queue}) async {
    // If a queue is passed (e.g., all songs on screen), load it. Otherwise stick to what we have or just one song.
    if (queue != null && queue.isNotEmpty) {
      currentQueue = queue;
    } else {
      if (!currentQueue.contains(song)) {
        currentQueue = [song];
      }
    }

    // Build the Just Audio native Playlist (ConcatenatingAudioSource)
    final audioSources = currentQueue.map((s) => AudioSource.uri(
        Uri.parse(s.song_url),
        tag: MediaItem(
          id: s.id,
          title: s.song_name,
          artist: s.artist,
          album: "My App Queue", // Optional
          artUri: Uri.parse(s.thumbnail_url),
        ),
      )).toList();

    final playlist = ConcatenatingAudioSource(children: audioSources);

    // Find the current song's actual position in the queue
    int initialIndex = currentQueue.indexOf(song);
    if (initialIndex == -1) initialIndex = 0;

    // Load up the playlist and jump directly to the clicked song
    await audioPlayer!.setAudioSource(playlist, initialIndex: initialIndex);

    audioPlayer?.play();
  }

  void playNext() {
    if (audioPlayer != null && audioPlayer!.hasNext) {
      audioPlayer!.seekToNext();
    }
  }

  void playPrevious() {
    if (audioPlayer != null) {
      // Logic: If they are 3 seconds into the song, restart it. If they are right at the start, go to the previous song.
      if (audioPlayer!.position.inSeconds > 3 || !audioPlayer!.hasPrevious) {
        audioPlayer!.seek(Duration.zero);
      } else {
        audioPlayer!.seekToPrevious();
      }
    }
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

  void clearState(String deletedSongId) {
    if (state?.id == deletedSongId) {
      state = null;
    }
    // Also quietly scrub it from the active queue so it doesn't try to play again!
    currentQueue.removeWhere((song) => song.id == deletedSongId);
  }

  void toggleShuffle() {
    if (audioPlayer != null) {
      final isShuffleEnabled = audioPlayer!.shuffleModeEnabled;
      audioPlayer!.setShuffleModeEnabled(!isShuffleEnabled);
      // Optional: actually re-roll the dice whenever it turns on so it feels fresh every time
      if (!isShuffleEnabled) {
        audioPlayer!.shuffle();
      }
    }
  }

  void toggleRepeat() {
    if (audioPlayer != null) {
      final currentMode = audioPlayer!.loopMode;
      if (currentMode == LoopMode.off) {
        audioPlayer!.setLoopMode(LoopMode.all);
      } else if (currentMode == LoopMode.all) {
        audioPlayer!.setLoopMode(LoopMode.one);
      } else {
        audioPlayer!.setLoopMode(LoopMode.off);
      }
    }
  }
}