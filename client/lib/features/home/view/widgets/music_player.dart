import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final currnetSong = ref.watch(currentSongProvider);
    final songNotifier = ref.watch(currentSongProvider.notifier);
     final userFavorites = ref.watch(
      currentUserProvider.select((data) => data?.favourites),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hexToColor(currnetSong!.hex_code), const Color(0xFF121212)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Pallete.transparentColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Pallete.transparentColor,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(
                CupertinoIcons.minus,
                color: Pallete.subtitleText,
                size: 60,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth;
                    return Center(
                      child: SizedBox(
                        width: size,
                        height: size,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: NetworkImage(currnetSong.thumbnail_url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currnetSong.song_name,
                            style: GoogleFonts.mulish(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currnetSong.artist,
                            style: GoogleFonts.mulish(
                              color: Pallete.subtitleText,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: const SizedBox()),
                      IconButton(
                        onPressed: () async {
                          await ref
                              .read(homeViewmodelProvider.notifier)
                              .favSong(songId: currnetSong.id);
                        },
                        icon: Icon(
                          userFavorites
                                  !.where((fav) => fav.song_id == currnetSong.id)
                                  .toList()
                                  .isNotEmpty
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                        ),
                        color: Pallete.whiteColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: songNotifier.audioPlayer!.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox();
                      }
                      final position = snapshot.data;
                      final duration = songNotifier.audioPlayer!.duration;
                      double sliderValue = 0.0;

                      if (position != null &&
                          duration != null &&
                          duration.inMilliseconds > 0) {
                        sliderValue =
                            position.inMilliseconds / duration.inMilliseconds;
                      }

                      if (sliderValue > 1.0) {
                        sliderValue = 1.0;
                      }
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape:
                                        SliderComponentShape.noOverlay,
                                  ),
                                  child: Slider(
                                    value: _dragValue ?? sliderValue,
                                    min: 0.0,
                                    max: 1.0,
                                    activeColor: Pallete.whiteColor,
                                    inactiveColor: Pallete.whiteColor
                                        .withValues(alpha: 0.117),

                                    onChangeStart: (val) {
                                      setState(() {
                                        _dragValue = val;
                                      });
                                    },

                                    onChanged: (val) {
                                      setState(() {
                                        _dragValue = val;
                                      });
                                    },

                                    onChangeEnd: (val) {
                                      songNotifier.audioPlayer!.seek(
                                        Duration(
                                          milliseconds:
                                              (duration!.inMilliseconds * val)
                                                  .toInt(),
                                        ),
                                      );
                                      setState(() {
                                        _dragValue = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              Text(
                                // FIX: Use the new formatter function!
                                songNotifier.formatDuration(position),
                                style: GoogleFonts.mulish(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                ),
                              ),
                              const Expanded(child: SizedBox()),
                              Text(
                                // FIX: Use the new formatter function!
                                songNotifier.formatDuration(duration),
                                style: GoogleFonts.mulish(
                                  color: Pallete.subtitleText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<bool>(
                          stream: songNotifier.audioPlayer?.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            final isShuffleEnabled = snapshot.data ?? false;
                            return IconButton(
                              onPressed: songNotifier.toggleShuffle,
                              icon: Icon(
                                CupertinoIcons.shuffle,
                                color: isShuffleEnabled ? Pallete.gradient2 : Pallete.whiteColor,
                              ),
                            );
                          }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: songNotifier.playPrevious,
                          icon: const Icon(
                            CupertinoIcons.backward_end_fill,
                            color: Pallete.whiteColor,
                            size: 30,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<bool>(
                          stream: songNotifier.audioPlayer?.playingStream,
                          builder: (context, snapshot) {
                            final isPlayingState = snapshot.data ?? false;

                            return IconButton(
                              onPressed: songNotifier.playPause,
                              icon: Icon(
                                isPlayingState
                                    ? CupertinoIcons.pause_circle_fill
                                    : CupertinoIcons.play_circle_fill,
                              ),
                              color: Pallete.whiteColor,
                              iconSize: 80,
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: songNotifier.playNext,
                          icon: const Icon(
                            CupertinoIcons.forward_end_fill,
                            color: Pallete.whiteColor,
                            size: 30,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<LoopMode>(
                          stream: songNotifier.audioPlayer?.loopModeStream,
                          builder: (context, snapshot) {
                            final loopMode = snapshot.data ?? LoopMode.off;
                            
                            IconData iconData = CupertinoIcons.repeat;
                            Color iconColor = Pallete.whiteColor;
                            
                            if (loopMode == LoopMode.all) {
                               iconColor = Pallete.gradient2; 
                            } else if (loopMode == LoopMode.one) {
                               iconData = CupertinoIcons.repeat_1;
                               iconColor = Pallete.gradient2; 
                            }

                            return IconButton(
                              onPressed: songNotifier.toggleRepeat,
                              icon: Icon(
                                iconData,
                                color: iconColor,
                              ),
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: () async {
                            // Safely grab the ID
                            final deleteId = currnetSong.id;
                            
                            // 1. Instantly pop out of the Music Player Drawer (good UX)
                            Navigator.pop(context);
                            
                            // 2. Kill the audio immediately
                            ref.read(currentSongProvider.notifier).audioPlayer?.stop();
                            
                            // 3. Tell the Python API to execute DELETE on PostgreSQL
                            await ref.read(homeViewmodelProvider.notifier).deleteSong(songId: deleteId);

                            // 4. Scrub the UI state cleanly out of the active Music Player
                            ref.read(currentSongProvider.notifier).clearState(deleteId);
                          },
                          icon: const Icon(
                            CupertinoIcons.delete,
                            color: Pallete.subtitleText,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Pallete.cardColor,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Consumer(
                                  builder: (context, ref, child) {
                                    final currentQueueSong = ref.watch(currentSongProvider);
                                    final currentQueueNotifier = ref.watch(currentSongProvider.notifier);
                                    
                                    return Container(
                                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Up Next',
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Pallete.whiteColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Expanded(
                                            child: ListView.builder(
                                              itemCount: currentQueueNotifier.currentQueue.length,
                                              itemBuilder: (context, index) {
                                                final qSong = currentQueueNotifier.currentQueue[index];
                                                final isPlaying = currentQueueSong != null && qSong.id == currentQueueSong.id;
                                                return ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  onTap: () {
                                                    currentQueueNotifier.updadeSong(qSong, queue: currentQueueNotifier.currentQueue);
                                                    Navigator.pop(context);
                                                  },
                                              leading: ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: Image.network(
                                                  qSong.thumbnail_url,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              title: Text(
                                                qSong.song_name,
                                                style: TextStyle(
                                                  color: isPlaying ? Pallete.gradient2 : Pallete.whiteColor,
                                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                qSong.artist,
                                                style: const TextStyle(color: Pallete.subtitleText),
                                              ),
                                              trailing: isPlaying 
                                                ? const Icon(Icons.multitrack_audio, color: Pallete.gradient1)
                                                : null,
                                            );
                                          },
                                        ),
                                      ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            CupertinoIcons.list_bullet,
                            color: Pallete.subtitleText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
