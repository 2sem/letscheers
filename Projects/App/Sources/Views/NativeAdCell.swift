//
//  NativeAdCell.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

private let relatedStocksAppStoreURL = URL(string: "https://apps.apple.com/app/id1189758512")!

// A cell view that displays a native ad in the category grid
struct NativeAdCell: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager
    let shouldLoadAd: Bool

    var body: some View {
        NativeAdSwiftUIView(adUnit: .native, shouldLoadAd: shouldLoadAd) { nativeAdContent in
            cellContent(nativeAdContent: nativeAdContent)
        }
    }

    @ViewBuilder
    private func cellContent(nativeAdContent: NativeAdContent?) -> some View {
        GeometryReader { geometry in
            let iconContainerSize = min(geometry.size.width * 0.65, geometry.size.height * 0.5)

            VStack(spacing: 12) {
                Spacer()

                if let ad = nativeAdContent {
                    // Google native ad loaded
                    ZStack {
                        Color(red: 0.938, green: 0.924, blue: 0.980)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)

                    Text(ad.headline ?? "광고")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(height: 24)

                    if let rating = ad.starRating {
                        Text(rating.stringValue)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                            .frame(height: 30)
                    } else {
                        Text(ad.advertiser ?? "")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                            .frame(height: 30)
                    }
                } else {
                    // Default: 관련주식검색기
                    ZStack {
                        Color(red: 0.938, green: 0.924, blue: 0.980)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image("othreapp")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(iconContainerSize * 0.1)
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)

                    Text("관련주식검색기")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(height: 24)

                    Text("4.6")
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
            .onTapGesture {
                if nativeAdContent == nil {
                    UIApplication.shared.open(relatedStocksAppStoreURL)
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
