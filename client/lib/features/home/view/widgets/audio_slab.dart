import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class AudioSlab extends ConsumerWidget {
  const AudioSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currnetSong = ref.watch(currentSongProvider);
    final songNotifier = ref.read(currentSongProvider.notifier);
    final userFavorites = ref.watch(
      currentUserProvider.select((data) => data?.favourites),
    );

    if (currnetSong == null) {
      return SizedBox();
    }
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return const MusicPlayer();
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 4),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 66,
              width: MediaQuery.of(context).size.width - 16,
              decoration: BoxDecoration(
                color: hexToColor(currnetSong.hex_code),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(currnetSong.thumbnail_url),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currnetSong.song_name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Pallete.whiteColor,
                            ),
                          ),
                          Text(
                            currnetSong.artist,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Pallete.subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
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
                      StreamBuilder<bool>(
                        stream: songNotifier.audioPlayer?.playingStream,
                        builder: (context, snapshot) {
                          final isPlayingState = snapshot.data ?? false;

                          return IconButton(
                            onPressed: songNotifier.playPause,
                            icon: Icon(
                              isPlayingState
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_fill,
                            ),
                            color: Pallete.whiteColor,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 1. INACTIVE BAR
            Positioned(
              bottom: 0,
              left: 0, // FIX: Back to 0
              right: 0,
              child: Container(
                height: 2,
                decoration: const BoxDecoration(
                  color: Pallete.inactiveSeekColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),

            // 2. ACTIVE BAR
            StreamBuilder<Duration?>(
              stream: songNotifier.audioPlayer?.positionStream,
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

                return Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    height: 2,
                    width:
                        sliderValue * (MediaQuery.of(context).size.width - 16),
                    decoration: BoxDecoration(
                      color: Pallete.whiteColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: const Radius.circular(4),
                        bottomRight: Radius.circular(
                          sliderValue == 1.0 ? 4 : 0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
