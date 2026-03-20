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
    // Watch the active page index so we can disable axis-locking on pages
    // that need native touch (e.g. WebView in SourceView).
    final currentPageIndex = ref.watch(bottomNavIndexProvider);

    ref.listen<int>(bottomNavIndexProvider, (previous, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });

    // Apply axis-locking on FeedPage (1) and SourceView (2).
    // This prevents diagonal swipes from accidentally switching pages.
    // SourceView re-enables it so the WebView doesn't trigger page changes
    // on diagonal scrolls; the WebView receives gestures via its own
    // gestureRecognizers once the PageView is locked by NeverScrollablePhysics.
    // SettingsPage (0) is left unrestricted — its ListView competes naturally.
    final bool axisLockEnabled = currentPageIndex == 1 || currentPageIndex == 2;

    return Scaffold(
      body: GestureDetector(
        onPanStart: axisLockEnabled ? _onPanStart : null,
        onPanUpdate: axisLockEnabled ? _onPanUpdate : null,
        onPanEnd: axisLockEnabled ? _onPanEnd : null,
        behavior: HitTestBehavior.translucent,
        child: PageView(
          controller: _pageController,
          physics: _pageViewLocked
              ? const NeverScrollableScrollPhysics()
              : const PageScrollPhysics(parent: ClampingScrollPhysics()),
          onPageChanged: (index) {
            controller.state = index;
            HapticFeedback.selectionClick();
            // Reset lock when the user swipes to a new page.
            if (_pageViewLocked) {
              setState(() {
                _pageViewLocked = false;
                _axisCommitted = false;
              });
            }
          },
          children: const [SettingsPage(), FeedPage(), SourceView()],
        ),
      ),
    );
  }
}
