/*
This is your public contract.

Contains:

Ad provider enum
Ad slot type
Ad render result (loaded / failed)
This is what FeedEntity talks to, not Google.
*/

enum AdProviderType {
  google,
  meta,
  promo;

  factory AdProviderType.fromString(String name) {
    switch (name) {
      case 'google':
        return google;
      case 'meta':
        return meta;
      case 'promo':
        return promo;
      default:
        return google;
    }
  }
}

enum AdRenderState {
  idle,
  loaded,
  failed;

  factory AdRenderState.fromString(String name) {
    switch (name) {
      case 'idle':
        return idle;
      case 'loaded':
        return loaded;
      case 'failed':
        return failed;
      default:
        return idle;
    }
  }
}

class AdMeta {
  final String slotId;
  final AdProviderType provider;
  final Map<String, dynamic>? config;

  const AdMeta({required this.slotId, required this.provider, this.config});
}

enum AdFormat {
  native,
  banner,
  interstitial;

  factory AdFormat.fromString(String name) {
    switch (name) {
      case 'native':
        return native;
      case 'banner':
        return banner;
      case 'interstitial':
        return interstitial;
      default:
        return native;
    }
  }
}