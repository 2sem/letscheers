//
//  ToastListNativeAdRow.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 3.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

/// A native ad interleaved into the toast list, styled to read like a `ToastRow`
/// rather than a boxed card.
///
/// - Reuses ``NativeAdSwiftUIView`` as the loader and click-tracking layer and
///   switches on its ``NativeAdPhase`` (the SwiftUI content only draws the visuals).
/// - Collapses to zero height when the ad fails to load, so there is no empty gap
///   and no repeated reload attempts (the loader is fire-once per instance).
/// - Matches toast rows: no border/card, `.padding(.vertical, 8)`, the shared row
///   background and the default list separator. The "광고" label and AdChoices
///   stay visible so it is never deceptive.
struct ToastListNativeAdRow: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    private let shouldLoadAd: Bool
    /// Matches `ToastListContent.backgroundRowColor` so the ad sits in the feed.
    private let backgroundRowColor: Color

    init(shouldLoadAd: Bool, backgroundRowColor: Color = .cardBackground) {
        self.shouldLoadAd = shouldLoadAd
        self.backgroundRowColor = backgroundRowColor
    }

    var body: some View {
        NativeAdSwiftUIView(adUnit: .toastListNativeAd, shouldLoadAd: shouldLoadAd) { phase in
            switch phase {
            case .loaded(let ad):
                loadedContent(ad)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(accessibilityText(for: ad))
                    .accessibilityAddTraits(.isButton)

            case .loading:
                placeholderContent
                    .accessibilityLabel("광고 불러오는 중")

            case .failed:
                // Collapse the row entirely — no gap, no separator, no retry.
                Color.clear
                    .frame(height: 0)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .accessibilityHidden(true)
            }
        }
        // Same translucent fill as the toast rows (also set at the list level).
        .listRowBackground(backgroundRowColor)
        .task {
            // Early-returns once ATT has already been requested.
            await adManager.requestAppTrackingIfNeed()
        }
    }

    // MARK: - Loaded

    private func loadedContent(_ ad: NativeAd) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("광고")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.secondary)

                Text(ad.headline ?? "추천 콘텐츠")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let subtitle = subtitle(for: ad) {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
            }

            Spacer()

            adIcon(ad)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private func adIcon(_ ad: NativeAd) -> some View {
        if let icon = ad.icon?.image {
            Image(uiImage: icon)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                // Keep the very top-trailing corner clear for the NativeAdView's
                // AdChoices overlay, which sits behind this content.
                .padding(.top, 2)
        } else if ad.mediaContent.aspectRatio > 0 {
            MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 2)
        }
        // else: no visual — Spacer still left-aligns the text.
    }

    private func subtitle(for ad: NativeAd) -> String? {
        if let body = ad.body, !body.isEmpty { return body }
        if let advertiser = ad.advertiser, !advertiser.isEmpty { return advertiser }
        return nil
    }

    // MARK: - Loading

    private var placeholderContent: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                skeletonLine(width: 34, height: 10)   // "광고"
                skeletonLine(width: 200, height: 16)  // headline
                skeletonLine(width: nil, height: 13)  // body
                skeletonLine(width: 140, height: 13)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 8)
                .fill(Color.iconContainer)
                .frame(width: 40, height: 40)
        }
        .padding(.vertical, 8)
        .accessibilityHidden(true)
    }

    private func skeletonLine(width: CGFloat?, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.iconContainer)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
    }

    // MARK: - Accessibility

    private func accessibilityText(for ad: NativeAd) -> String {
        let headline = ad.headline ?? ""
        let detail = ad.callToAction ?? ad.advertiser ?? ""
        return "광고. \(headline). \(detail)"
    }
}
