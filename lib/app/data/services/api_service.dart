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
      responseType: ResponseType.plain,
    ),
  );

  Future<PlaylistResponse> fetchPlaylist() async {
    final response = await _dio.get(playlistUrl);

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to load playlist (status ${response.statusCode})');
    }

    dynamic decoded;
    try {
      decoded = response.data is String
          ? jsonDecode(response.data as String)
          : response.data;
    } catch (e) {
      throw Exception('Failed to parse playlist JSON: $e');
    }

    // jsonDecode always produces String-keyed maps for JSON objects, but
    // depending on how the value flows through Dio it can surface as
    // Map<dynamic, dynamic> rather than the exact Map<String, dynamic>
    // type — checking for `Map` (not the generic-specific variant) and
    // then normalizing avoids a false "unexpected format" failure.
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      return PlaylistResponse.fromJson(map);
    }

    throw Exception('Unexpected playlist format (got ${decoded.runtimeType})');
  }
}
