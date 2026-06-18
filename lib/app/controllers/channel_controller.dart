import 'package:get/get.dart';

import '../data/models/channel_model.dart';
import '../data/services/api_service.dart';

/// Plain GetxController used with GetBuilder.
/// No reactive (.obs) variables are used — state changes are pushed
/// to the UI explicitly via update().
class ChannelController extends GetxController {
  final ApiService _apiService = ApiService();

  List<Channel> channels = [];
  List<Channel> filteredChannels = [];
  PlaylistInfo? info;

  bool isLoading = false;
  String? errorMessage;
  String searchQuery = '';

  @override
  void onInit() {
    super.onInit();
    fetchChannels();
  }

  Future<void> fetchChannels() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final result = await _apiService.fetchPlaylist();
      channels = result.channels;
      info = result.info;
      _applyFilter();
    } catch (_) {
      errorMessage = 'Could not load channels. Pull down to retry.';
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Used by RefreshIndicator (pull-to-refresh).
  Future<void> refreshChannels() async {
    await fetchChannels();
  }

  void search(String query) {
    searchQuery = query;
    _applyFilter();
    update();
  }

  void _applyFilter() {
    if (searchQuery.trim().isEmpty) {
      filteredChannels = channels;
      return;
    }
    final q = searchQuery.toLowerCase();
    filteredChannels =
        channels.where((c) => c.name.toLowerCase().contains(q)).toList();
  }
}
