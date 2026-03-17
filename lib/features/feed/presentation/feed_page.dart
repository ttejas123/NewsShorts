import 'package:bl_inshort/core/ads/ads_providers.dart';
import 'package:bl_inshort/core/ads/presentation/ad_slot_widget.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/features/feed/presentation/widgets/feed_cards.dart';
import 'package:bl_inshort/features/shell/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bl_inshort/features/feed/providers.dart';
import 'package:bl_inshort/core/analytics/analytics_client.dart';
import 'widgets/stacked_card_feed.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load initial batch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(feedControllerProvider.notifier).loadInitial();
      ref.read(analyticsClientProvider).logScreenView(screenName: 'FeedPage');

      // 🔥 restore position
      final index = ref.read(currentFeedIndexProvider);
      if (_scrollController.hasClients) {
        final viewportHeight = _scrollController.position.viewportDimension;
        _scrollController.jumpTo(index * viewportHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final adsRuntime = ref.watch(adsRuntimeProvider);
    final state = ref.watch(feedControllerProvider);
    final bottomNav = ref.read(bottomNavIndexProvider.notifier);

    // ✅ Log screen view when THIS tab becomes active
    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (next == 1) {
        ref.read(analyticsClientProvider).logScreenView(screenName: 'FeedPage');
      }
    });

    if (state.isInitialLoading && state.items.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load feed\n${state.error}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Scaffold(body: Center(child: Text('No news yet')));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          /// 🔹 STACKED SCROLL FEED
          SafeArea(
            top: true, // respects status bar
            bottom: false,
            child: StackedCardFeed(
              controller: _scrollController,
              itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
              // isLoadingMore: state.isLoadingMore,
              onCardIndexChanged: (index) {
                ref.read(currentFeedIndexProvider.notifier).state = index;

                final total = state.items.length;

                // 🔥 Trigger 'view' interaction
                if (index < total) {
                  final item = state.items[index];
                  ref.read(feedControllerProvider.notifier).toggleUserAction(
                    feedId: item.id,
                    actionType: 'view',
                  );
                }

                if (index >= total - 3 &&
                    state.hasMore &&
                    !state.isLoadingMore) {
                  ref.read(feedControllerProvider.notifier).loadMore();
                }
              },
              itemBuilder: (context, index) {
                if (index >= state.items.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final item = state.items[index];

                if (item.provider.type == ItemType.Advertisement) {
                  return AdSlotWidget(
                    meta: item,
                    runtime: adsRuntime,
                    fallback: FeedCard(
                      item: item,
                      count: state.count,
                      index: index,
                    ),
                  );
                }

                return FeedCard(item: item, count: state.count, index: index);
              },
            ),
          ),

          /// 🔹 TOP OVERLAY CONTROLS
          _FeedTopOverlay(
            onSettingsTap: () {
              bottomNav.state = 0;
            },
            onRefreshTap: () {
              ref.read(feedControllerProvider.notifier).loadInitial();
              // scroll to top
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeedTopOverlay extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onRefreshTap;

  const _FeedTopOverlay({
    required this.onSettingsTap,
    required this.onRefreshTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      top: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _OverlayButton(icon: Icons.settings, onTap: onSettingsTap),
            const Spacer(),
            _OverlayButton(icon: Icons.refresh, onTap: onRefreshTap),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _OverlayButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: colors.onSurface),
        ),
      ),
    );
  }
}