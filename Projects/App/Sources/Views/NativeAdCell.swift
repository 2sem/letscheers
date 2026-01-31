//
//  NativeAdCell.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

// A cell view that displays a native ad in the category grid
struct NativeAdCell: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager
    @AppStorage("LaunchCount") private var launchCount = 0

    var body: some View {
        // Only show ad after 1+ launches
        if launchCount > 1 {
            NativeAdSwiftUIView(adUnit: .native) { nativeAd in
                GeometryReader { geometry in
                    VStack(spacing: 12) {
                        Spacer()

                        // Icon/Media container - matches category cell size
                        let iconContainerSize = min(geometry.size.width * 0.65, geometry.size.height * 0.5)

                        if let ad = nativeAd {
                            // Native ad loaded - show media
                            ZStack {
                                Color(red: 0.938, green: 0.924, blue: 0.980)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                                    .scaledToFit()
                                    .padding(iconContainerSize * 0.15)
                            }
                            .frame(width: iconContainerSize, height: iconContainerSize)

                            // Headline as category name
                            Text(ad.headline ?? "광고")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .frame(height: 24)

                            // Star rating as count - matches category count display
                            if let rating = ad.starRating {
                                Text(rating.stringValue)
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                                    .frame(height: 30)
                            } else {
                                // Fallback to advertiser or empty
                                Text(ad.advertiser ?? "")
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                                    .frame(height: 30)
                            }

                        } else {
                            // Fallback - matches ads placeholder cell design
                            ZStack {
                                Color(red: 0.938, green: 0.924, blue: 0.980)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                Image(systemName: "megaphone.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(iconContainerSize * 0.15)
                                    .foregroundColor(Color(red: 0.479, green: 0.262, blue: 0.871))
                            }
                            .frame(width: iconContainerSize, height: iconContainerSize)

                            Text("광고")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))

                            Text("")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                                .frame(height: 30)
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                    .overlay(alignment: .topTrailing) {
                        AdMarkView()
                            .padding(8)
                    }
                    .task {
                        if nativeAd != nil {
                            await adManager.requestAppTrackingIfNeed()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Ad Mark
private struct AdMarkView: View {
    private let text: String = "Ad"
    var body: some View {
        Text(text)
            .font(.caption2)
            .bold()
            .foregroundStyle(.white)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.3))
            )
            .accessibilityLabel("Advertisement")
    }
}
