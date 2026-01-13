import 'package:bl_inshort/core/ads/ads_providers.dart';
import 'package:bl_inshort/core/ads/presentation/ad_slot_widget.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/features/feed/presentation/widgets/snap_scroll_physics.dart';
import 'package:bl_inshort/features/shell/navigation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bl_inshort/features/feed/providers.dart';
import 'widgets/feed_cards.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load initial batch
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(feedControllerProvider.notifier).loadInitial();

      // 🔥 restore position
      final index = ref.read(currentFeedIndexProvider);
      if (_scrollController.hasClients) {
        final viewportHeight = _scrollController.position.viewportDimension;
        _scrollController.jumpTo(index * viewportHeight);
      }
    });

    // Infinite scroll trigger (we’ll keep this, but it now works with snapping too)
    _scrollController.addListener(_onScroll);
  }

  int _lastIndex = 0;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final viewportHeight = position.viewportDimension;
    if (viewportHeight == 0) return;

    final index = (position.pixels / viewportHeight).round();

    if (index != _lastIndex) {
      _lastIndex = index;
      ref.read(currentFeedIndexProvider.notifier).state = index;
    }

    final totalItems = ref.read(feedControllerProvider).items.length;

    // 🔥 Trigger loadMore ONLY near end
    if (index >= totalItems - 3 && // last 2–3 pages
        ref.read(feedControllerProvider).hasMore &&
        !ref.read(feedControllerProvider).isLoadingMore) {
      debugPrint('🔄 Trying to load more');
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adsRuntime = ref.watch(adsRuntimeProvider);
    final state = ref.watch(feedControllerProvider);
    final bottomNavigationController = ref.read(
      bottomNavIndexProvider.notifier,
    );
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (state.isInitialLoading && state.items.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'Failed to load feed.\n${state.error}',
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
          /// 🔹 FEED (Scrollable)
          SafeArea(
            top: true, // respects status bar
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemHeight = constraints.maxHeight;

                return ListView.builder(
                  controller: _scrollController,
                  physics: SnapScrollPhysics(
                    itemExtent: itemHeight,
                    parent: const ClampingScrollPhysics(),
                  ),
                  padding: EdgeInsets.zero,
                  itemExtent: itemHeight,
                  cacheExtent: itemHeight * 0.5,
                  itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.items.length - 2 &&
                        state.isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (index >= state.items.length) {
                      return const SizedBox.shrink();
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

                    return FeedCard(
                      item: item,
                      count: state.count,
                      index: index,
                    );
                  },
                );
              },
            ),
          ),

          /// 🔹 FLOATING TOP CONTROLS (Overlay)
          _FeedTopOverlay(
            onSettingsTap: () {
              bottomNavigationController.state = 0;
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
      top: true, // 👈 keeps buttons BELOW status bar
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
