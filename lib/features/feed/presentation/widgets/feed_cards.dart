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
      case FeedLayoutType.photoDominant:
        return _PhotoDominantCard(item: item);
      case FeedLayoutType.textDominant:
        return _TextDominantCard(item: item);
      case FeedLayoutType.gallery:
        return _GalleryCard(item: item);
      case FeedLayoutType.story:
        return StoryCard(item: item);
      case FeedLayoutType.htmlViewCard:
        return _HTMLViewCard(item: item);
      case FeedLayoutType.browserCard:
        return _BrowserViewCard(item: item);
      case FeedLayoutType.standardCard:
        return StandardVisualCard(item: item, count: count, index: index);
    }
  }
}

// 1) Photo-dominant layout (big image, text overlay/under)
class _PhotoDominantCard extends StatelessWidget {
  final FeedEntity item;

  const _PhotoDominantCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.resources.isNotEmpty)
            CachedNetworkImage(
              imageUrl: item.resources[0].url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: size.width,
                height: size.height,
                color: Colors.grey.shade300,
              ),
              errorWidget: (_, __, ___) => Icon(Icons.image_not_supported),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.7),
                  // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.0),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.source.name.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2) Text-dominant layout (more like Inshorts)
class _TextDominantCard extends StatelessWidget {
  final FeedEntity item;

  const _TextDominantCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.resources.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: item.resources[0].url,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: size.width,
                      height: size.height,
                      color: Colors.grey.shade300,
                    ),
                    errorWidget: (_, __, ___) =>
                        Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
            ...[
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '• ${item.source}',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 3) Gallery layout (horizontal slider)
class _GalleryCard extends StatefulWidget {
  final FeedEntity item;

  const _GalleryCard({required this.item});

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<String> get _images => widget.item.resources
      .where((res) => res.contentType.name == 'image')
      .map((res) => res.url)
      .toList();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final images = _images;

    return Container(
      width: size.width,
      height: size.height,
      color: colors.surface,
      child: Stack(
        children: [
          // main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final url = images[index];
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: size.width,
                            height: size.height,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                          ),
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.image_not_supported),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.source.name.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32), // space for indicator overlay
              // 👇 bottom indicator (dots + "line"-style active)
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // dot + line indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(images.length, (index) {
                        final isActive = index == _currentIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          height: 6,
                          width: isActive ? 16 : 6, // line vs dot
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              isActive ? 0.95 : 0.5,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4) Story-style layout (full bleed image, center text)
class _StoryCard extends StatelessWidget {
  final FeedEntity item;

  const _StoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      color: colors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (item.resources.isNotEmpty)
            CachedNetworkImage(
              imageUrl: item.resources.first.url,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: size.width,
                height: size.height,
                color: Colors.grey.shade300,
              ),
              errorWidget: (_, __, ___) => Icon(Icons.image_not_supported),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    item.source.name.toUpperCase(),
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: Colors.white70),
                  ),
                ),
                const Spacer(),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5) html-style layout (full bleed image, center text)
class _HTMLViewCard extends StatelessWidget {
  final FeedEntity item;

  const _HTMLViewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
      child: AdvancedWebView(
        initialHtml: item.html,
        title: item.title,
        enableJavaScript: true,
        showAppBar: false,
        backgroundColor: Colors.white,
        allowInlineMediaPlayback: true,
      ),
    );
  }
}

// 6) Webview-style layout
class _BrowserViewCard extends StatelessWidget {
  final FeedEntity item;

  const _BrowserViewCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      color: Colors.black,
      child: AdvancedWebView(
        initialUrl: item.webUrl,
        title: item.title,
        enableJavaScript: true,
        showAppBar: false,
        backgroundColor: Colors.white,
        allowInlineMediaPlayback: true,
      ),
    );
  }
}

class RelatedImagesRow extends StatelessWidget {
  final List<ResourceEntity> resources;
  const RelatedImagesRow({super.key, required this.resources});

  @override
  Widget build(BuildContext context) {
    final visibleCount = resources.length.clamp(1, 3);
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      margin: const EdgeInsets.only(left: 10, right: 20, top: 0, bottom: 8),
      height: 64,
      child: Stack(
        clipBehavior: Clip.none, // 🔥 allow overflow
        children: [
          // 🔹 Main pill
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.only(
                left: 18,
                right: 16, // ❌ no arrow space reserved
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFD3D5D9),
                    Color(0xFFB4B7BD),
                    Color(0xFF8D9198),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Messi Kolkata Event Row",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // 🔹 Overlapping images
                  SizedBox(
                    width: 44 + (visibleCount - 1) * 22,
                    height: 44,
                    child: Stack(
                      children: [
                        ...resources
                            .take(visibleCount)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) {
                              final idx = entry.key;
                              final resource = entry.value;
                              return _imageCircle(
                                left: idx * 22,
                                imageUrl: resource.url,
                              );
                            }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Arrow button (HALF OUTSIDE – EXACT MATCH)
          Positioned(
            right: -18, // 🔥 critical: pushes it outside
            top: 12,
            bottom: 12,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => RelatedImagesGallery(resources: resources),
                  ),
                );
              },
              child: Container(
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromARGB(255, 0, 0, 0),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Color(0xFF2F80ED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _imageCircle({required double left, required String imageUrl}) {
    return Positioned(
      left: left,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // shape: BoxShape.circle,
          // border: Border.all(color: Colors.white, width: 2),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class RelatedImagesGallery extends StatefulWidget {
  final List<ResourceEntity> resources;

  const RelatedImagesGallery({super.key, required this.resources});

  @override
  State<RelatedImagesGallery> createState() => _RelatedImagesGalleryState();
}

class _RelatedImagesGalleryState extends State<RelatedImagesGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _controlsVisible = true;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ===============================
            // MAIN IMAGE SLIDER
            // ===============================
            GestureDetector(
              onTap: _toggleControls,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.resources.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: widget.resources[index].url,
                        fit: BoxFit.contain,
                        progressIndicatorBuilder: (context, child, progress) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ===============================
            // TOP BAR CONTROLS
            // ===============================
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // TODO: integrate share logic
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ===============================
            // PAGE INDICATOR
            // ===============================
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.resources.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

    final repo = ref.read(feedRepositoryProvider);
    final shareCallback = () async {
      await repo.toggleUserAction(feedId: item.id, actionType: 'share');
      if (context.mounted) {
        _shareLink(context, "blinshort://feed/${item.id}", item.title);
      }
    };
    final onLike = () async {
      await repo.toggleUserAction(feedId: item.id, actionType: 'like');
    };
    final onSave = () async {
      await repo.toggleUserAction(feedId: item.id, actionType: 'save');
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

  const _FloatingActionRow({
    required this.onLike,
    required this.onSave,
    required this.shareLink,
    required this.isLiked,
    required this.isSaved,
  });

  @override
  State<_FloatingActionRow> createState() => _FloatingActionRowState();
}

class _FloatingActionRowState extends State<_FloatingActionRow> {
  bool _isLiked = false;
  bool _isSaved = false;
  double _likeScale = 1.0;
  double _saveScale = 1.0;
  double _shareTurns = 0.0;
  bool _isLoadingLike = false;
  bool _isLoadingSave = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _isSaved = widget.isSaved;
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

    setState(() {
      _likeScale = 1.3;
      _isLoadingLike = true;
    });

    try {
      await widget.onLike();
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _likeScale = 1.0;
          _isLoadingLike = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (_isLoadingSave) return;

    setState(() {
      _saveScale = 1.3;
      _isLoadingSave = true;
    });

    try {
      await widget.onSave();
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _saveScale = 1.0;
          _isLoadingSave = false;
        });
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
                  child: AnimatedScale(
                    scale: _likeScale,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
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
                  child: AnimatedScale(
                    scale: _saveScale,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
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

/// ─────────────────────────────────────────────
/// BOTTOM CTA
/// ─────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _BottomCTA({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [Color(0xFF2E3440), Color(0xFF1B1F27)]
                : const [Color(0xFFF3F4F7), Color(0xFFE6E8ED)],
          ),
        ),
        child: Text(
          'Tap to know more',
          style: textTheme.titleSmall?.copyWith(height: 1.4),
        ),
      ),
    );
  }
}

class AdFeedCard extends StatelessWidget {
  final Widget ad;

  const AdFeedCard({required this.ad});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 560,
      color: colors.surface,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: ad),

                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "Sponsored",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
