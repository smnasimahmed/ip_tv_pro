class Channel {
  final String name;
  final String url;

  Channel({required this.name, required this.url});

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      name: (json['name'] ?? '').toString().trim(),
      url: (json['url'] ?? '').toString().trim(),
    );
  }

  static const _fileExtensions = {
    'mp4', 'mp3', 'mkv', 'avi', 'mov', 'm4v', 'wav', 'aac', 'flac', 'webm',
  };

  bool get isStreamingFormat {
    final path = Uri.tryParse(url)?.path ?? url;
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) return true;
    final ext = path.substring(dotIndex + 1).toLowerCase();
    return !_fileExtensions.contains(ext);
  }
}

class PlaylistInfo {
  final String owner;
  final String team;
  final String generatedBy;
  final String version;
  final int totalChannels;
  final String lastUpdate;

  PlaylistInfo({
    this.owner = '',
    this.team = '',
    this.generatedBy = '',
    this.version = '',
    this.totalChannels = 0,
    this.lastUpdate = '',
  });

  factory PlaylistInfo.fromJson(Map<String, dynamic> json) {
    return PlaylistInfo(
      owner: json['owner']?.toString() ?? '',
      team: json['Team']?.toString() ?? '',
      generatedBy: json['generated_by']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      totalChannels: int.tryParse(json['total_channels']?.toString() ?? '') ?? 0,
      lastUpdate: json['last_update']?.toString() ?? '',
    );
  }
}

class PlaylistResponse {
  final PlaylistInfo info;
  final List<Channel> channels;

  PlaylistResponse({required this.info, required this.channels});

  factory PlaylistResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['channels'] as List<dynamic>? ?? [];

    final channels = rawList
        .whereType<Map>()
        .map((e) => Channel.fromJson(Map<String, dynamic>.from(e)))
        .where((c) => c.name.isNotEmpty && c.url.isNotEmpty && c.isStreamingFormat)
        .toList();

    final rawInfo = json['info'];
    final info = rawInfo is Map
        ? PlaylistInfo.fromJson(Map<String, dynamic>.from(rawInfo))
        : PlaylistInfo();

    return PlaylistResponse(
      info: info,
      channels: channels,
    );
  }
}
