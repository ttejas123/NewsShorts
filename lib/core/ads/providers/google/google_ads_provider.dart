import 'package:bl_inshort/data/models/feeds/feed_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ads_types.dart';
import '../ad_provider.dart';

// --- Native Ad ---

class _GoogleNativeAdWidgetState extends State<_GoogleNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  double _height(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / 1.91) + 110; // MUST match iOS layout
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    debugPrint('🧪 Loading Google Native Ad');
    debugPrint('🧪 adUnitId = ${widget.adUnitId}');
    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId,
      factoryId: 'feedNativeAd', // IMPORTANT
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('🟢 Google Native Ad loaded');
          setState(() => _isLoaded = true);
          widget.onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('🔴 Google Native Ad failed to load: $error');
          widget.onFailed();
        },
      ),
      request: const AdRequest(),
    );

    _nativeAd!.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = _height(context);
    if (!_isLoaded) {
      // Keep height to avoid jump
      return SizedBox(height: height);
    }

    return SizedBox.expand(
      child: AdWidget(ad: _nativeAd!),
    );
  }
}

class _GoogleNativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  const _GoogleNativeAdWidget({
    required this.adUnitId,
    required this.onLoaded,
    required this.onFailed,
  });

  @override
  State<_GoogleNativeAdWidget> createState() => _GoogleNativeAdWidgetState();
}

// --- Banner Ad ---

class _GoogleBannerAdWidgetState extends State<_GoogleBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('🟢 Google Banner Ad loaded');
          widget.onLoaded();
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('🔴 Google Banner Ad failed to load: $error');
          widget.onFailed();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bannerHeight = 50.0;
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: bannerHeight);
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

class _GoogleBannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  const _GoogleBannerAdWidget({
    required this.adUnitId,
    required this.onLoaded,
    required this.onFailed,
  });

  @override
  State<_GoogleBannerAdWidget> createState() => _GoogleBannerAdWidgetState();
}

// --- Affiliate Ad ---

class _GoogleAffiliateAdWidget extends StatefulWidget {
  final String? imageUrl;
  final String? redirectUrl;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  const _GoogleAffiliateAdWidget({
    required this.imageUrl,
    required this.redirectUrl,
    required this.onLoaded,
    required this.onFailed,
  });

  @override
  State<_GoogleAffiliateAdWidget> createState() =>
      _GoogleAffiliateAdWidgetState();
}

class _GoogleAffiliateAdWidgetState extends State<_GoogleAffiliateAdWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
        widget.onFailed();
      } else {
        widget.onLoaded();
      }
    });
  }

  Future<void> _openUrl() async {
    final url = widget.redirectUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }
    return Center(
      child: InkWell(
        onTap: _openUrl,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          placeholder: (_, __) => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) {
            WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFailed());
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- Provider ---

class GoogleAdsProvider implements AdProvider {
  @override
  AdProviderType get type => AdProviderType.google;

  @override
  Widget buildAd({
    required FeedEntity meta,
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) {
    final subType = meta.provider.subType.toLowerCase();

    if (subType == 'native') {
      return _GoogleNativeAdWidget(
        adUnitId: meta.provider.id,
        onLoaded: onLoaded,
        onFailed: onFailed,
      );
    }

    if (subType == 'banner') {
      return _GoogleBannerAdWidget(
        adUnitId: meta.provider.id,
        onLoaded: onLoaded,
        onFailed: onFailed,
      );
    }

    // Native or legacy (e.g. "google" from old mock)
    
    return _GoogleAffiliateAdWidget(
        imageUrl: meta.provider.imageUrl,
        redirectUrl: meta.provider.redirectUrl,
        onLoaded: onLoaded,
        onFailed: onFailed,
    );
  }
}
