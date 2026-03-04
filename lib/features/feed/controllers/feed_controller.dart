import 'package:bl_inshort/core/logging/console.dart';
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
}
