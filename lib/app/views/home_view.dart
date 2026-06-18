import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/channel_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/channel_tile.dart';
import 'player_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChannelController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Pro'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: 'Search channels...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GetBuilder<ChannelController>(
              builder: (controller) => _buildList(context, controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, ChannelController controller) {
    if (controller.isLoading && controller.channels.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.channels.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primaryPurple,
        onRefresh: controller.refreshChannels,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final list = controller.filteredChannels;

    if (list.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.primaryPurple,
        onRefresh: controller.refreshChannels,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Text('No channels found', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.primaryPurple,
      onRefresh: controller.refreshChannels,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final channel = list[index];
          return ChannelTile(
            channel: channel,
            onTap: () => Get.to(() => PlayerView(channel: channel)),
          );
        },
      ),
    );
  }
}
