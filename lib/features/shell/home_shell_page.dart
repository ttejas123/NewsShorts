import 'package:bl_inshort/features/settings/presentation/settings_page.dart';
import 'package:bl_inshort/features/source/presentation/source_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'navigation_providers.dart';
import 'package:bl_inshort/features/feed/presentation/feed_page.dart';

class HomeShellPage extends ConsumerStatefulWidget {
  const HomeShellPage({super.key});

  @override
  ConsumerState<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends ConsumerState<HomeShellPage> {
  late final PageController _pageController;

  // ─── Axis-lock state ─────────────────────────────────────────────────────
  /// Whether the outer PageView is allowed to scroll this gesture.
  bool _pageViewLocked = false;

  /// Accumulated delta while we haven't yet committed to an axis.
  double _panDx = 0;
  double _panDy = 0;

  /// True once we have committed to one axis for the current gesture.
  bool _axisCommitted = false;

  /// Threshold (in logical pixels) before we commit to an axis.
  static const double _axisLockThreshold = 6.0;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(bottomNavIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails _) {
    _panDx = 0;
    _panDy = 0;
    _axisCommitted = false;
    // Don't lock yet – wait until we have enough delta to decide.
    if (_pageViewLocked) {
      setState(() => _pageViewLocked = false);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_axisCommitted) return; // already decided for this gesture

    _panDx += details.delta.dx.abs();
    _panDy += details.delta.dy.abs();

    final total = _panDx + _panDy;
    if (total < _axisLockThreshold) return; // not enough movement yet

    _axisCommitted = true;

    final lockPageView = _panDy > _panDx; // vertical dominates → lock PageView
    if (lockPageView != _pageViewLocked) {
      setState(() => _pageViewLocked = lockPageView);
    }
  }

  void _onPanEnd(DragEndDetails _) {
    if (_pageViewLocked) {
      setState(() {
        _pageViewLocked = false;
        _axisCommitted = false;
      });
    } else {
      _axisCommitted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(bottomNavIndexProvider.notifier);

    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      body: GestureDetector(
        // We use onPan* (which tracks both axes simultaneously) to detect
        // the dominant direction and route accordingly.
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        // Make sure taps and other gestures still pass through.
        behavior: HitTestBehavior.translucent,
        child: PageView(
          controller: _pageController,
          // When the vertical axis is dominant, freeze horizontal paging so
          // the child's vertical scroll (e.g. StackedCardFeed) wins.
          physics: _pageViewLocked
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(parent: ClampingScrollPhysics()),
          onPageChanged: (index) {
            controller.state = index;
            HapticFeedback.selectionClick();
          },
          children: const [SettingsPage(), FeedPage(), SourceView()],
        ),
      ),
    );
  }
}
