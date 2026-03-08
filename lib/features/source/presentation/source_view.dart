import 'package:bl_inshort/features/feed/providers.dart';
import 'package:bl_inshort/features/webview/presentation/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SourceView extends ConsumerWidget {
  const SourceView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFeedItem = ref.watch(currentFeedItemProvider);
    if (currentFeedItem == null) {
      return const Center(child: Text("No source available"));
    }

    // TODO: I just want to show devices battery percentage in the app bar so nothing else need not even padding
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: AdvancedWebView(
          key: ValueKey(currentFeedItem.id),
          initialUrl: currentFeedItem.webUrl,
          showAppBar: false,
        ),
      ),
    );
  }
}
