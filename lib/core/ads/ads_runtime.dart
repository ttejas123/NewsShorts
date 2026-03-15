/*
    Equivalent to AuthService.

    Responsibilities:

    Accept ad metadata from feed
    Select correct provider
    Orchestrate lifecycle
    Never render UI directly
    Feed never knows who renders the ad
*/

import 'package:bl_inshort/core/ads/ads_types.dart';
import 'package:bl_inshort/data/models/feeds/feed_entity.dart';

import 'package:bl_inshort/core/ads/ads_registry.dart';
import 'package:bl_inshort/core/ads/providers/ad_provider.dart';

class AdsRuntime {
  final AdsRegistry _registry;

  AdsRuntime(this._registry);

  AdProvider resolveProvider(FeedEntity meta) {
    return _registry.getProvider(
      AdProviderType.fromString(meta.provider.name),
    );
  }
}
