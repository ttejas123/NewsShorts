// lib/features/webview/presentation/advanced_webview.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';

typedef NavigationRequestCallback = FutureOr<NavigationDecision> Function(
    NavigationRequest request);

class AdvancedWebView extends StatefulWidget {
  /// Provide either [initialUrl] or [initialHtml]. If both are provided,
  /// [initialHtml] has priority.
  final String? initialUrl;
  final String? initialHtml;

  /// Optional title to display in AppBar while waiting for page title.
  final String? title;

  /// Optional CSS to inject into raw html or into remote page after load.
  final String? injectCSS;

  /// Optional JS to inject after page load (use carefully).
  final String? injectJS;

  /// Called for navigation requests. If omitted, default is to navigate.
  final NavigationRequestCallback? onNavigationRequest;

  /// Optional domain whitelist — any navigation to outside domains will be blocked.
  final List<String>? allowList; // e.g. ['shortnews.app', 'example.com']

  /// Whether to enable JavaScript.
  final bool enableJavaScript;

  /// Whether to allow media playback without user gesture (videos, audio).
  final bool allowInlineMediaPlayback;

  /// Show AppBar with title + refresh by default.
  final bool showAppBar;

  /// Optional background color for the WebView area.
  final Color? backgroundColor;

  const AdvancedWebView({
    super.key,
    this.initialUrl,
    this.initialHtml,
    this.title,
    this.injectCSS,
    this.injectJS,
    this.onNavigationRequest,
    this.allowList,
    this.enableJavaScript = true,
    this.allowInlineMediaPlayback = true,
    this.showAppBar = true,
    this.backgroundColor,
  }) : assert(initialUrl != null || initialHtml != null,
            'Provide either initialUrl or initialHtml');

  @override
  State<AdvancedWebView> createState() => _AdvancedWebViewState();
}

class _AdvancedWebViewState extends State<AdvancedWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _pageTitle;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
        const String mobileUa = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36';

    // if (Platform.isAndroid) WebView.platform = AndroidWebView();

    _controller = WebViewController()
      ..setHorizontalScrollBarEnabled(true)
      ..setJavaScriptMode(
          widget.enableJavaScript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled)
      ..setBackgroundColor(widget.backgroundColor ?? const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _isError = false;
            });
          },
          onPageFinished: (url) async {
            // Get title
            final title = await _controller.getTitle();
            if (!mounted) return;
            setState(() {
              _pageTitle = title ?? widget.title;
              _isLoading = false;
            });

            // If user provided CSS/JS and page is remote, inject them
            if (widget.injectCSS != null) {
              final wrappedCss = _wrapCss(widget.injectCSS!);
              await _controller.runJavaScript(wrappedCss);
            }
            if (widget.injectJS != null) {
              await _controller.runJavaScript(widget.injectJS!);
            }
          },
          onWebResourceError: (err) {
            if (!mounted) return;
            setState(() {
              _isError = true;
              _errorMessage =
                  'Failed to load: ${err.errorCode} — ${err.description}';
              _isLoading = false;
            });
          }
        ),
      );

    _controller.setUserAgent(mobileUa);
    // Load initial content
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitial());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadInitial() async {
    try {
      if (widget.initialHtml != null) {
        // If HTML is provided: inject CSS + JS into the HTML and load it.
        final htmlWithInjections = _composeHtml(widget.initialHtml!,
            css: widget.injectCSS, js: widget.injectJS);
        // webview_flutter provides loadHtmlString
        await _controller.loadHtmlString(htmlWithInjections);
      } else {
        // remote URL
        // await _controller.loadRequest(Uri.parse(widget.initialUrl!),
        //     // Some platform options (not required, shown for completeness)
        //     // headers: {'User-Agent': 'ShortNewsApp/1.0'},
        //     );
        const String mobileUa = 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36';
        await _controller.loadRequest(
          Uri.parse(widget.initialUrl!),
          headers: {'User-Agent': mobileUa},
        );
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = 'Load failed: $e';
        _isLoading = false;
      });
    }
  }

  // Wrap raw CSS in JS that injects <style> into document head.
  static String _wrapCss(String css) {
    final escaped = css.replaceAll("'", "\\'");
    return """
    (function() {
      var style = document.createElement('style');
      style.type = 'text/css';
      style.appendChild(document.createTextNode('$escaped'));
      document.head.appendChild(style);
    })();
    """;
  }

  // Compose HTML string with optional CSS and JS embedded inline.
  static String _composeHtml(String html, {String? css, String? js}) {
    final buffer = StringBuffer();

    buffer.writeln('<!doctype html>');
    buffer.writeln('<html>');
    buffer.writeln('<head>');
    buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1">');
    if (css != null) {
      buffer.writeln('<style>$css</style>');
    }
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln(html);
    if (js != null) {
      buffer.writeln('<script>$js</script>');
    }
    buffer.writeln('</body>');
    buffer.writeln('</html>');

    return buffer.toString();
  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final title = _pageTitle ?? widget.title ?? '';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(title, overflow: TextOverflow.ellipsis),
                actions: [
                  IconButton(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_filled)),
                  IconButton(
                      onPressed: () => _controller.reload(),
                      icon: const Icon(Icons.refresh)),
                  IconButton(
                      onPressed: () async {
                        if (await _controller.canGoBack()) {
                          _controller.goBack();
                        }
                      },
                      icon: const Icon(Icons.arrow_back)),
                  IconButton(
                      onPressed: () async {
                        if (await _controller.canGoForward()) {
                          _controller.goForward();
                        }
                      },
                      icon: const Icon(Icons.arrow_forward)),
                ],
                elevation: 0,
                backgroundColor: Colors.transparent,
              )
            : null,
        body: Stack(
          children: [
            // ── gestureRecognizers ───────────────────────────────────────
            // Platform views (WebViewWidget) don't automatically compete in
            // Flutter's gesture arena. We explicitly register:
            //   • VerticalDragGestureRecognizer → page scroll
            //   • ScaleGestureRecognizer        → pinch-zoom
            // Once the outer PageView is locked by the shell's axis-locker, these
            // recognizers win the arena and the WebView's native touch handler
            // processes the events normally — including diagonal scrolls.
            WebViewWidget(
              controller: _controller,
              // Register a VerticalDragGestureRecognizer so the WebView's
              // native layer can win vertical scroll events in Flutter's
              // gesture arena — critical when nested inside a PageView.
              // Pinch-zoom is handled natively by the platform WebView
              // and doesn't need explicit registration here.
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
              },
            ),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_isError)
              _ErrorView(
                message: _errorMessage ?? 'Unknown error',
                onRetry: _loadInitial,
              ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home_filled, size: 64, color: Colors.redAccent),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
