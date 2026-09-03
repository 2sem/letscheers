//
//  ToastListNativeAdRow.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 3.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

/// A row-shaped native ad interleaved into the toast list.
///
/// - Reuses ``NativeAdSwiftUIView`` / ``NativeAdLoaderCoordinator`` as the loader
///   and click-tracking layer (the SwiftUI content below only draws the visuals).
/// - Collapses to zero height when the ad fails to load, so there is no empty gap
///   and no repeated reload attempts (the coordinator is fire-once per instance).
/// - Dark-theme card styling consistent with `ToastRow`, clearly labelled `광고`.
struct ToastListNativeAdRow: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    private let shouldLoadAd: Bool
    /// Matches `ToastListContent.backgroundRowColor` so the ad reads as part of the list.
    private let backgroundRowColor: Color

    @State private var loadState: NativeAdLoaderCoordinator.LoadState = .idle

    init(shouldLoadAd: Bool, backgroundRowColor: Color = .cardBackground) {
        self.shouldLoadAd = shouldLoadAd
        self.backgroundRowColor = backgroundRowColor
    }

    var body: some View {
        Group {
            if loadState == .failed {
                // Collapse the row entirely — no gap, no separator.
                Color.clear
                    .frame(height: 0)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .accessibilityHidden(true)
            } else {
                NativeAdSwiftUIView(
                    adUnit: .toastListNativeAd,
                    shouldLoadAd: shouldLoadAd,
                    onLoadStateChange: { loadState = $0 }
                ) { nativeAd in
                    card(for: nativeAd)
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        .task {
            // Early-returns once ATT has already been requested.
            await adManager.requestAppTrackingIfNeed()
        }
    }

    // MARK: - Card

    @ViewBuilder
    private func card(for nativeAd: NativeAd?) -> some View {
        ZStack(alignment: .topLeading) {
            if let ad = nativeAd {
                loadedContent(ad)
            } else {
                placeholderContent
            }

            AdBadgeView()
                .padding(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundRowColor)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.accentPurple.opacity(0.35), lineWidth: 1)
        )
        // Leave the top-trailing corner free so the NativeAdView's AdChoices
        // overlay (drawn behind this card) is never clipped.
        .padding(.trailing, 2)
        .padding(.top, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText(for: nativeAd))
        .accessibilityAddTraits(.isButton)
    }

    private func loadedContent(_ ad: NativeAd) -> some View {
        HStack(alignment: .center, spacing: 12) {
            mediaThumbnail(ad)

            VStack(alignment: .leading, spacing: 4) {
                Text(ad.headline ?? "추천 콘텐츠")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let body = ad.body, !body.isEmpty {
                    Text(body)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else if let advertiser = ad.advertiser, !advertiser.isEmpty {
                    Text(advertiser)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            if let cta = ad.callToAction, !cta.isEmpty {
                Text(cta)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(Color.accentPurple))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func mediaThumbnail(_ ad: NativeAd) -> some View {
        ZStack {
            Color.iconContainer
            if let icon = ad.icon?.image {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
            } else {
                MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                    .scaledToFill()
            }
        }
        .frame(width: 52, height: 52)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var placeholderContent: some View {
        HStack(alignment: .center, spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.iconContainer)
                .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.iconContainer)
                    .frame(height: 14)
                    .frame(maxWidth: 160)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.iconContainer.opacity(0.6))
                    .frame(height: 12)
                    .frame(maxWidth: .infinity)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .redacted(reason: .placeholder)
    }

    private func accessibilityText(for nativeAd: NativeAd?) -> String {
        guard let ad = nativeAd else { return "광고 불러오는 중" }
        let headline = ad.headline ?? ""
        let cta = ad.callToAction ?? ""
        return "광고. \(headline). \(cta)"
    }
}

// MARK: - Ad Badge

private struct AdBadgeView: View {
    var body: some View {
        Text("광고")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(Color.black.opacity(0.45)))
            .accessibilityHidden(true)
    }
}
