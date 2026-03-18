import 'dart:ui';
// import 'package:bl_inshort/core/config/globles.dart';
import 'package:bl_inshort/data/dto/feed/feed_dto.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';
import 'package:bl_inshort/data/models/feeds/resource_entity.dart';
import 'package:bl_inshort/features/feed/presentation/widgets/story_feed_card.dart';
import 'package:bl_inshort/features/feed/providers.dart';
import 'package:bl_inshort/features/webview/presentation/webview_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class FeedCard extends StatelessWidget {
  final FeedEntity item;
  final int count;
  final int index;

  const FeedCard({
    super.key,
    required this.item,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    switch (item.layout) {
      case FeedLayoutType.standardCard:
        return StandardVisualCard(item: item, count: count, index: index);
      default:
        return StandardVisualCard(item: item, count: count, index: index);
    }
  }
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
  if (diff.inHours < 24) return '${diff.inHours} hrs ago';
  return '${diff.inDays} days ago';
}

class _BottomInfoStrip extends StatelessWidget {
  final FeedEntity item;
  final VoidCallback shareLink;
  final int numberRemaining;

  const _BottomInfoStrip({
    super.key,
    required this.item,
    required this.shareLink,
    required this.numberRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bool showRemaining =
        numberRemaining > 0 &&
        numberRemaining <= 10 &&
        (numberRemaining % 5 == 0 || numberRemaining <= 2);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 🔵 Blue pill
          if (showRemaining) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                numberRemaining == 1
                    ? 'Last story below'
                    : '$numberRemaining stories remaining below',
                style: textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          const SizedBox(height: 10),

          /// Divider + time + share (ALL INSIDE STACK)
          SizedBox(
            height: 40, // important: gives Stack a hit-test box
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                /// Divider (disable hit testing)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Divider(
                      height: 1,
                      thickness: 0.6,
                      color: colors.onSurface.withOpacity(0.15),
                    ),
                  ),
                ),

                /// Time (left)
                Positioned(
                  left: 0,
                  top: -5,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo(item.publishedAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ],
                  ),
                ),

                /// Share button (right)
                Positioned(
                  right: 0,
                  top: 1,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: shareLink,
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.share,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  top: 28,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          'more at ',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Yalla News",
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// Source
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _shareLink(BuildContext context, String url, String subject) {
  final box = context.findRenderObject() as RenderBox?;

  if (box == null) return;

  Share.share(
    url,
    subject: subject,
    sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
  );
}

class StandardVisualCard extends ConsumerWidget {
  final FeedEntity item;
  final int count;
  final int index;

  const StandardVisualCard({
    super.key,
    required this.item,
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    // Removed fixed height constants in favor of LayoutBuilder proportions

    final feedController = ref.read(feedControllerProvider.notifier);
    final shareCallback = () async {
      await feedController.toggleUserAction(feedId: item.id, actionType: 'share');
      if (context.mounted) {
        _shareLink(context, "blinshort://feed/${item.id}", item.title);
      }
    };
    final onLike = () async {
      await feedController.toggleUserAction(feedId: item.id, actionType: 'like');
    };
    final onSave = () async {
      await feedController.toggleUserAction(feedId: item.id, actionType: 'save');
    };
    return Container(
      height: 560,
      color: colors.surface,
      child: Column(
        children: [
          /// IMAGE + OVERLAYS
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;
                final imageHeight = totalHeight * 0.35;
                final contentHeight = totalHeight * 0.65;
                const floatingHalfHeight = 18.0; // Approx half height of the pill

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    /// Image
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: imageHeight,
                      child: CachedNetworkImage(
                        imageUrl: item.resources.isNotEmpty
                            ? item.resources.first.url
                            : '',
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: Colors.grey.shade300),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                      ),
                    ),

                    /// Content (Bottom 65%)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: contentHeight,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
                        decoration: BoxDecoration(
                          color: colors.surface,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Title
                            Text(
                              item.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Description
                            Expanded(
                              child: Text(
                                item.description,
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(height: 1.45),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// Meta
                            Text(
                              '${item.source.name} • ${item.author.name}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// 🔥 FLOATING ACTION ROW
                    Positioned(
                      left: 16,
                      right: 16,
                      top: imageHeight - floatingHalfHeight,
                      child: _FloatingActionRow(
                        key: ValueKey(item.id),
                        id: item.id,
                        onLike: onLike,
                        onSave: onSave,
                        shareLink: shareCallback,
                        isLiked: item.interactions.like.status,
                        isSaved: item.interactions.saved.status,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          /// ✅ NEW BOTTOM INFO (added)
          _BottomInfoStrip(
            key: ValueKey(item.id),
            numberRemaining: count - (index + 1),
            item: item,
            shareLink: shareCallback,
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// FLOATING ROW
/// ─────────────────────────────────────────────

class _FloatingActionRow extends StatefulWidget {
  final Future<void> Function() onLike;
  final Future<void> Function() onSave;
  final Future<void> Function() shareLink;
  final bool isLiked;
  final bool isSaved;
  final String id;

  const _FloatingActionRow({
    required super.key,
    required this.id,
    required this.onLike,
    required this.onSave,
    required this.shareLink,
    required this.isLiked,
    required this.isSaved,
  });

  @override
  State<_FloatingActionRow> createState() => _FloatingActionRowState();
}

class _FloatingActionRowState extends State<_FloatingActionRow>
    with TickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;

  late AnimationController _likeController;
  late AnimationController _saveController;
  late Animation<double> _likeAnimation;
  late Animation<double> _saveAnimation;

  double _shareTurns = 0.0;
  bool _isLoadingLike = false;
  bool _isLoadingSave = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _likeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4).chain(
          CurveTween(curve: Curves.easeOutQuart),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0).chain(
          CurveTween(curve: Curves.easeInQuad),
        ),
        weight: 50,
      ),
    ]).animate(_likeController);

    _saveAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4).chain(
          CurveTween(curve: Curves.easeOutQuart),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0).chain(
          CurveTween(curve: Curves.easeInQuad),
        ),
        weight: 50,
      ),
    ]).animate(_saveController);
  }

  @override
  void dispose() {
    _likeController.dispose();
    _saveController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FloatingActionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLiked != widget.isLiked) {
      _isLiked = widget.isLiked;
    }
    if (oldWidget.isSaved != widget.isSaved) {
      _isSaved = widget.isSaved;
    }
  }

  Future<void> _handleLike() async {
    if (_isLoadingLike) return;

    // Optimistic Update
    setState(() {
      _isLiked = !_isLiked;
    });

    // Animation & Haptics
    HapticFeedback.lightImpact();
    _likeController.forward(from: 0.0);

    _isLoadingLike = true;
    try {
      await widget.onLike();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
      }
    } finally {
      if (mounted) {
        _isLoadingLike = false;
      }
    }
  }

  Future<void> _handleSave() async {
    if (_isLoadingSave) return;

    // Optimistic Update
    setState(() {
      _isSaved = !_isSaved;
    });

    // Animation & Haptics
    HapticFeedback.lightImpact();
    _saveController.forward(from: 0.0);

    _isLoadingSave = true;
    try {
      await widget.onSave();
    } catch (e) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
        });
      }
    } finally {
      if (mounted) {
        _isLoadingSave = false;
      }
    }
  }

  Future<void> _handleShare() async {
    setState(() {
      _shareTurns += 1.0;
    });
    await widget.shareLink();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        _GlassPill(
          child: Row(
            children: [
              const Icon(
                Icons.fiber_new_sharp,
                size: 12,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 6),
              Text(
                'Yalla News',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const Spacer(),
        _GlassPill(
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleLike,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  child: ScaleTransition(
                    scale: _likeAnimation,
                    child: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : colors.onSurfaceVariant,
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleSave,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  child: ScaleTransition(
                    scale: _saveAnimation,
                    child: Icon(
                      _isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: _isSaved ? Colors.yellow : colors.onSurfaceVariant,
                      size: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleShare,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  child: AnimatedRotation(
                    turns: _shareTurns,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.share,
                      color: colors.onSurfaceVariant,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ─────────────────────────────────────────────
/// GLASS PILL
/// ─────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  final Widget child;

  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.surface.withOpacity(0.7),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
