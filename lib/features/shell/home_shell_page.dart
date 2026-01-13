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

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(bottomNavIndexProvider.notifier);

    // ✅ LISTEN HERE (correct place)
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
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          controller.state = index;
          HapticFeedback.selectionClick();
        },
        children: const [SettingsPage(), FeedPage(), SourceView()],
      ),
    );
  }
}
