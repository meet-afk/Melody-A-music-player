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
    ref.watch(homeViewmodelProvider); // Bind explicitly so it automatically updates when we delete anything
    
    final recentlyPlayedSongs = ref
        .watch(homeViewmodelProvider.notifier)
        .getRecentPlayedSongs();
    final currentSong = ref.watch(currentSongProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.only( top: 20, left: 4, right: 4),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
      
          children: [
            if (recentlyPlayedSongs.isNotEmpty) ...[
              Padding(
            padding: const EdgeInsets.only(bottom: 36, left: 16, right: 16),
        
                child: SizedBox(
              height: 280,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Disable grid scrolling so page scrolls
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 230,
                      childAspectRatio: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: recentlyPlayedSongs.length > 4 ? 4 : recentlyPlayedSongs.length, // Limit to 4 for a clean square look
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
                              const SizedBox(width: 10),
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
            ],
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Latest Today',
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
                      height: 220,
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
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      song.thumbnail_url,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 150,
                                              height: 150,
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
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      song.song_name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      song.artist,
                                      style: const TextStyle(
                                        color: Pallete.subtitleText,
                                        fontSize: 12,
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

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your Favorites',
                style: GoogleFonts.mulish(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ref
                .watch(getAllFavSongsProvider)
                .when(
                  data: (songs) {
                    if (songs.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 20),
                        child: Text(
                          "You haven't favorited any songs yet.",
                          style: TextStyle(color: Pallete.subtitleText),
                        ),
                      );
                    }
                    return SizedBox(
                      height: 220,
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
                                    borderRadius: BorderRadius.circular(100), // Circle shape for favorites!
                                    child: Image.network(
                                      song.thumbnail_url,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 150,
                                              height: 150,
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
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      song.song_name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
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

            const SizedBox(height: 100), // Add padding for the bottom nav bar / active player
          ],
        ),
      ),
    );
  }
}
