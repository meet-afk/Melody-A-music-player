import 'dart:io';
import 'dart:ui';

import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(Ref ref) async {
  final token = ref.watch(currentUserProvider.select((user) => user!.token));
  final res = await ref.watch(homeRepositoryProvider).getAllSongs(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getAllFavSongs(Ref ref) async {
  final token = ref.watch(currentUserProvider.select((user) => user!.token));
  final res = await ref
      .watch(homeRepositoryProvider)
      .getAllFavSongs(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@Riverpod(keepAlive: true)
class HomeViewmodel extends _$HomeViewmodel {
  late HomeRepository _homeRepository;
  late HomeLocalRepository _homeLocalRepository;

  @override
  AsyncValue? build() {
    _homeRepository = ref.watch(homeRepositoryProvider);

    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);

    return null;
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songNAme,
    required String artist,
    required Color selectColor,
  }) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.uploadSong(
      selectedAudio: selectedAudio,
      selectedThumbnail: selectedThumbnail,
      songNAme: songNAme,
      artist: artist,
      hexCode: rgbToHex(selectColor),
      token: ref.read(currentUserProvider)!.token,
    );

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
        break;

      case Right(value: final r):
        state = AsyncValue.data(r);
        break;
    }
  }

  List<SongModel> getRecentPlayedSongs() {
    return _homeLocalRepository.loadSongs();
  }

  Future<void> favSong({required String songId}) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.favSong(
      token: ref.read(currentUserProvider)!.token,
      songId: songId,
    );

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
        break;

      case Right(value: final r):
        _favSongSuccess(r, songId);
        break;
    }
  }

  AsyncValue _favSongSuccess(bool isFavourited, String songId) {
    final userNotifier = ref.read(currentUserProvider.notifier);
    if (isFavourited) {
      userNotifier.addUser(
        ref
            .read(currentUserProvider)!
            .copyWith(
              favourites: [
                ...ref.read(currentUserProvider)!.favourites,
                FavSongModel(id: "", song_id: songId, user_id: ""),
              ],
            ),
      );
    } else {
      userNotifier.addUser(
        ref
            .read(currentUserProvider)!
            .copyWith(
              favourites: ref
                  .read(currentUserProvider)!
                  .favourites
                  .where((fav) => fav.song_id != songId)
                  .toList(),
            ),
      );
    }
    ref.invalidate(getAllFavSongsProvider);
    return state = AsyncValue.data(isFavourited);
  }

  Future<void> deleteSong({required String songId}) async {
    state = const AsyncValue.loading();
    final res = await _homeRepository.deleteSong(
      token: ref.read(currentUserProvider)!.token,
      songId: songId,
    );

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);
        break;

      case Right(value: final r):
        // Automatically refresh the whole app's track lists!
        ref.invalidate(getAllSongsProvider);
        ref.invalidate(getAllFavSongsProvider);
        
        // Completely banish it from the Hive local offline storage (Recently Played)
        _homeLocalRepository.deleteLocalSong(songId);
        
        // Remove it from local user memory just in case it was a favorite
        final userNotifier = ref.read(currentUserProvider.notifier);
        userNotifier.addUser(
          ref.read(currentUserProvider)!.copyWith(
            favourites: ref.read(currentUserProvider)!.favourites
                .where((fav) => fav.song_id != songId)
                .toList(),
          ),
        );
        state = AsyncValue.data(r);
        break;
    }
  }
}
