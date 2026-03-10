import 'package:flutter/material.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:bl_inshort/core/ads/ads_runtime.dart';
import 'package:bl_inshort/features/feed/presentation/widgets/ad_feed_card.dart';

class AdSlotWidget extends StatefulWidget {
  final FeedEntity meta;
  final AdsRuntime runtime;
  final Widget fallback;

  const AdSlotWidget({
    super.key,
    required this.meta,
    required this.runtime,
    required this.fallback,
  });

  @override
  State<AdSlotWidget> createState() => _AdSlotWidgetState();
}

class _AdSlotWidgetState extends State<AdSlotWidget> {
  bool _failed = false;
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return widget.fallback;
    }

    final provider = widget.runtime.resolveProvider(widget.meta);

    return AdFeedCard(
      ad: provider.buildAd(
        meta: widget.meta,
        onLoaded: () {
          setState(() {
            _loaded = true;
          });
        },
        onFailed: () {
          setState(() {
            _failed = true;
          });
        },
      ),
    );
  }
}