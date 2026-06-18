import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/channel_model.dart';

class ApiService {
  // Source playlist (provided by the user).
  static const String playlistUrl =
      'https://raw.githubusercontent.com/abusaeeidx/Mrgify-BDIX-IPTV/main/Channels_data.json';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      // Fetch as plain text first — raw.githubusercontent.com does not
      // always send an application/json content-type, which would
      // otherwise cause Dio to skip auto-parsing.
      responseType: ResponseType.json,
    ),
  );

  Future<PlaylistResponse> fetchPlaylist() async {
    final response = await _dio.get(playlistUrl);

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to load playlist (status ${response.statusCode})');
    }

    // final dynamic decoded = response.data is String
    //     ? jsonDecode(response.data as String)
    //     : response.data;

    if (response.data is Map<String, dynamic>) {
      return PlaylistResponse.fromJson(response.data);
    }

    throw Exception('Unexpected playlist format');
  }
}
