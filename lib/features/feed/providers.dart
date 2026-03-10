import 'package:bl_inshort/data/models/feeds/feed_entity.dart';
import 'package:bl_inshort/features/feed/controllers/feed_controller.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bl_inshort/core/network/api_client.dart';
import 'package:bl_inshort/data/repositories/feed_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(settingsControllerProvider);
  return ApiClient(mockMode: true, sysuid: settings.sysuid);
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final client = ref.read(apiClientProvider);
  return FeedRepository(client.dio);
});

final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  return FeedController(ref.read);
});

final currentFeedIndexProvider = StateProvider<int>((ref) => 0);

final currentFeedItemProvider = Provider<FeedEntity?>((ref) {
  final index = ref.watch(currentFeedIndexProvider);
  final feedState = ref.watch(feedControllerProvider);

  if (feedState.items.isEmpty) return null;
  if (index < 0 || index >= feedState.items.length) return null;

  return feedState.items[index];
});