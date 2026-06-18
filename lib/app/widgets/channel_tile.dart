import 'package:flutter/material.dart';

import '../data/models/channel_model.dart';

class ChannelTile extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const ChannelTile({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primary.withOpacity(0.18),
        child: Icon(Icons.live_tv_rounded, color: primary),
      ),
      title: Text(
        channel.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(Icons.play_circle_outline, color: Colors.white.withOpacity(0.6)),
      onTap: onTap,
    );
  }
}
