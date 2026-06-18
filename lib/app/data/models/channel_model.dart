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
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .where((c) => c.name.isNotEmpty && c.url.isNotEmpty)
        .toList();

    return PlaylistResponse(
      info: PlaylistInfo.fromJson(
        json['info'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      channels: channels,
    );
  }
}
