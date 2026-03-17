import 'package:bl_inshort/data/repositories/feed_repository.dart';
import 'package:bl_inshort/features/settings/provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';

import 'package:bl_inshort/features/feed/providers.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';

typedef Reader = T Function<T>(ProviderListenable<T>);

class FeedState {
  final List<FeedEntity> items;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int? cursor;
  final int pageSize;
  final int count;
  final Object? error;

  const FeedState({
    required this.items,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.cursor,
    required this.pageSize,
    required this.count,
    required this.error,
  });

  factory FeedState.initial() => const FeedState(
    items: [],
    isInitialLoading: false,
    isLoadingMore: false,
    hasMore: true,
    cursor: null,
    pageSize: 20,
    count: 0,
    error: null,
  );

  FeedState copyWith({
    List<FeedEntity>? items,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? cursor,
    int? pageSize,
    int? count,
    Object? error,
  }) {
    return FeedState(
      items: items ?? this.items,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      cursor: cursor ?? this.cursor,
      pageSize: pageSize ?? this.pageSize,
      count: count ?? this.count,
      error: error,
    );
  }
}

class FeedController extends StateNotifier<FeedState> {
  FeedController(this._read) : super(FeedState.initial());

  final Reader _read;

  FeedRepository get _repo => _read(feedRepositoryProvider);

  Future<void> loadInitial() async {
    if (state.isInitialLoading) return;

    state = state.copyWith(isInitialLoading: true, error: null);

    try {
      final response = await _repo.fetchFeed(
        cursor: null,
        limit: state.pageSize,
        lang: _read(settingsControllerProvider).selectedLanguage?.code ?? "en",
      );

      state = state.copyWith(
        isInitialLoading: false,
        items: response['entity'],
        count: response['count'],
        hasMore: response['hasMore'],
        cursor: response['cursor'],
      );
    } catch (e) {
      state = state.copyWith(isInitialLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final response = await _repo.fetchFeed(
        cursor: state.cursor,
        limit: state.pageSize,
        lang: _read(settingsControllerProvider).selectedLanguage?.code ?? "en",
      );

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...response['entity']],
        count: response['count'],
        hasMore: response['hasMore'],
        cursor: response['cursor'],
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> toggleUserAction({
    required String feedId,
    required String actionType,
  }) async {
    // 1. Find the item
    final index = state.items.indexWhere((item) => item.id == feedId);
    if (index == -1) return;

    final item = state.items[index];
    final currentInteractions = item.interactions;

    // 2. Prepare new interactions (Optimistic)
    late FeedInteractionsEntity updatedInteractions;

    if (actionType == 'like') {
      updatedInteractions = currentInteractions.copyWith(
        like: currentInteractions.like.copyWith(
          status: !currentInteractions.like.status,
        ),
      );
    } else if (actionType == 'save' || actionType == 'saved') {
      updatedInteractions = currentInteractions.copyWith(
        saved: currentInteractions.saved.copyWith(
          status: !currentInteractions.saved.status,
        ),
      );
    } else if (actionType == 'share') {
      updatedInteractions = currentInteractions.copyWith(
        share: currentInteractions.share.copyWith(
          status: true, // share is usually just triggered
        ),
      );
    } else if (actionType == 'view') {
      // if (currentInteractions.view.status) return; // Already viewed
      updatedInteractions = currentInteractions.copyWith(
        view: currentInteractions.view.copyWith(
          status: true,
        ),
      );
    } else {
      return;
    }

    // 3. Update local state
    final updatedItems = [...state.items];
    updatedItems[index] = item.copyWith(interactions: updatedInteractions);
    state = state.copyWith(items: updatedItems);

    // 4. Sync with repository
    try {
      await _repo.toggleUserAction(feedId: feedId, actionType: actionType);
    } catch (e) {
      // Revert on error
      final revertedItems = [...state.items];
      revertedItems[index] = item; // item is the original one
      state = state.copyWith(items: revertedItems);
      rethrow;
    }
  }
}
