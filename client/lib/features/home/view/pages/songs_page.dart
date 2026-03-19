import 'package:client/core/provider/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/wigets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayedSongs = ref
        .watch(homeViewmodelProvider.notifier)
        .getRecentPlayedSongs();
    final currentSong = ref.watch(currentSongProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only( top: 15, left: 4, right: 4),
      decoration: currentSong == null ? null : BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: [
            hexToColor(currentSong.hex_code),
            Pallete.transparentColor,
          ],
          stops: [0.0, 0.7],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
    
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 36, left: 16, right: 16),
    
            child: SizedBox(
              height: 260,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 230,
                  childAspectRatio: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: recentlyPlayedSongs.length,
                itemBuilder: (context, index) {
                  final currentSong = recentlyPlayedSongs[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(currentSongProvider.notifier)
                          .updadeSong(currentSong, queue: recentlyPlayedSongs);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Pallete.borderColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          // 1. The Image
                          Container(
                            width: 60,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  currentSong.thumbnail_url,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
    
                          // 2. The Spacing
                          const SizedBox(width: 10),
    
                          // 3. The Text
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                currentSong.song_name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Recents',
              style: GoogleFonts.mulish(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ref
              .watch(getAllSongsProvider)
              .when(
                data: (songs) {
                  return SizedBox(
                    height: 260,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return GestureDetector(
                          onTap: () {
                            ref
                                .read(currentSongProvider.notifier)
                                .updadeSong(song, queue: songs);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Optional: rounds the corners
                                  child: Image.network(
                                    song.thumbnail_url,
                                    width: 180,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                          return Container(
                                            width: 180,
                                            height: 180,
                                            color: Colors.grey[850],
                                            child: const Icon(
                                              Icons.music_note,
                                              size: 50,
                                              color: Colors.white54,
                                            ),
                                          );
                                        },
                                  ),
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                  child: Text(
                                    song.song_name,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(
                                  child: Text(
                                    song.artist,
                                    style: TextStyle(
                                      color: Pallete.subtitleText,
                                      fontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                error: (error, st) {
                  return Center(child: Text(error.toString()));
                },
                loading: () => const Loader(),
              ),
        ],
      ),
    );
  }
}
