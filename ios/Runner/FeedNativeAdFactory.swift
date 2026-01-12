import UIKit
import google_mobile_ads

class FeedNativeAdFactory: NSObject, FLTNativeAdFactory {

  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable : Any]? = nil
  ) -> GADNativeAdView {

    // ===========================
    // ROOT AD VIEW
    // ===========================
    let adView = GADNativeAdView()
    adView.backgroundColor = .black
    adView.clipsToBounds = true
    adView.layer.cornerRadius = 14
    adView.translatesAutoresizingMaskIntoConstraints = true
    adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // ===========================
    // HERO MEDIA (IMAGE / VIDEO)
    // ===========================
    let mediaView = GADMediaView()
    mediaView.mediaContent = nativeAd.mediaContent
    mediaView.contentMode = .scaleAspectFill
    mediaView.clipsToBounds = true
    mediaView.translatesAutoresizingMaskIntoConstraints = false

    adView.addSubview(mediaView)
    adView.mediaView = mediaView

    // ===========================
    // BOTTOM OVERLAY
    // ===========================
    let overlay = UIView()
    overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
    overlay.translatesAutoresizingMaskIntoConstraints = false
    overlay.isUserInteractionEnabled = false // 🔑 REQUIRED
    adView.addSubview(overlay)

    // ===========================
    // SPONSORED LABEL
    // ===========================
    let sponsoredLabel = UILabel()
    sponsoredLabel.text = "Sponsored"
    sponsoredLabel.textColor = .lightGray
    sponsoredLabel.font = UIFont.systemFont(ofSize: 11, weight: .medium)
    sponsoredLabel.translatesAutoresizingMaskIntoConstraints = false

    // ===========================
    // HEADLINE
    // ===========================
    let headlineLabel = UILabel()
    headlineLabel.text = nativeAd.headline
    headlineLabel.textColor = .white
    headlineLabel.font = UIFont.boldSystemFont(ofSize: 15)
    headlineLabel.numberOfLines = 2
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false

    // ===========================
    // CTA BUTTON
    // ===========================
    let ctaButton = UIButton(type: .system)
    ctaButton.setTitle(nativeAd.callToAction ?? "Open", for: .normal)
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.backgroundColor = UIColor.systemBlue
    ctaButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    ctaButton.layer.cornerRadius = 8
    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
    ctaButton.translatesAutoresizingMaskIntoConstraints = false
    ctaButton.removeFromSuperview()

    // ===========================
    // ADD OVERLAY CONTENT
    // ===========================
    overlay.addSubview(sponsoredLabel)
    overlay.addSubview(headlineLabel)
    overlay.addSubview(ctaButton)

    // ===========================
    // AUTO LAYOUT (FULLY CONSTRAINED)
    // ===========================
    NSLayoutConstraint.activate([

      // Media fills entire card
      mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
      mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),

      // Aspect ratio (AdMob recommended)
      mediaView.heightAnchor.constraint(equalTo: mediaView.widthAnchor, multiplier: 1 / 1.91),

      // Overlay pinned to bottom
      // overlay.topAnchor.constraint(equalTo: mediaContainer.bottomAnchor),
      overlay.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
      overlay.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
      overlay.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
      overlay.heightAnchor.constraint(equalToConstant: 110),

      // Sponsored label
      sponsoredLabel.topAnchor.constraint(equalTo: overlay.topAnchor, constant: 8),
      sponsoredLabel.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 12),

      // Headline
      headlineLabel.topAnchor.constraint(equalTo: sponsoredLabel.bottomAnchor, constant: 4),
      headlineLabel.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 12),
      headlineLabel.trailingAnchor.constraint(equalTo: ctaButton.leadingAnchor, constant: -10),

      // CTA button
      ctaButton.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
      ctaButton.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -12)
    ])

    // ===========================
    // GOOGLE REQUIRED BINDINGS
    // ===========================
    adView.headlineView = headlineLabel
    adView.callToActionView = ctaButton
    adView.mediaView = mediaView
    adView.nativeAd = nativeAd

    return adView
  }
}
