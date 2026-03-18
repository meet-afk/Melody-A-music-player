import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constant.dart';
import 'package:client/core/failure/appfailure.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Either<Appfailure, String>> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songNAme,
    required String artist,
    required String hexCode,
    required String token,
  }) async {
    try {
      final request = http.MultipartRequest(
        "POST",
        Uri.parse('${ServerConstant.baseUrl}/song/upload'),
      );
      request
        ..files.addAll([
          await http.MultipartFile.fromPath("song", selectedAudio.path),
          await http.MultipartFile.fromPath(
            "thumbnail",
            selectedThumbnail.path,
          ),
        ])
        ..fields.addAll({
          "song_name": songNAme,
          "artist": artist,
          "hex_code": hexCode,
        })
        ..headers.addAll({"x-auth-token": token});

      final response = await request.send();
      if (response.statusCode == 201) {
        return Left(Appfailure(await response.stream.bytesToString()));
      }

      return Right(await response.stream.bytesToString());
    } catch (e) {
      return Left(Appfailure(e.toString()));
    }
  }

  Future<Either<Appfailure, List<SongModel>>> getAllSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.baseUrl}/song/list'),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );

      var resBodyMap = jsonDecode(res.body);
      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Appfailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];

      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }

      return Right(songs);
    } catch (e) {
      return Left(Appfailure(e.toString()));
    }
  }

  Future<Either<Appfailure, bool>> favSong({
    required String token,
    required String songId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstant.baseUrl}/song/favourite'),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
        body: jsonEncode({"song_id": songId}),
      );

      var resBodyMap = jsonDecode(res.body);
      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Appfailure(resBodyMap['detail']));
      }

      return Right(resBodyMap['message']);
    } catch (e) {
      return Left(Appfailure(e.toString()));
    }
  }

  Future<Either<Appfailure, List<SongModel>>> getAllFavSongs({
    required String token,
  }) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstant.baseUrl}/song/list/favourites'),
        headers: {"Content-Type": "application/json", "x-auth-token": token},
      );

      var resBodyMap = jsonDecode(res.body);
      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(Appfailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];

      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map['song']));
      }

      return Right(songs);
    } catch (e) {
      return Left(Appfailure(e.toString()));
    }
  }
}
