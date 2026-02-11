//
//  NativeAdSwiftUIView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

// MARK: - NativeAdContent

struct NativeAdContent {
    let headline: String?
    let starRating: NSDecimalNumber?
    let advertiser: String?
    let mediaContent: MediaContent?
}

extension NativeAdContent {
    init(nativeAd: NativeAd) {
        headline = nativeAd.headline
        starRating = nativeAd.starRating
        advertiser = nativeAd.advertiser
        mediaContent = nativeAd.mediaContent
    }
}

// MARK: - NativeAdLoaderCoordinator

@Observable
final class NativeAdLoaderCoordinator: NSObject, ObservableObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    var nativeAdContent: NativeAdContent?
    private var adLoader: AdLoader?

    func load(withAdManager manager: SwiftUIAdManager, forUnit unit: SwiftUIAdManager.GADUnitName) {
        guard let adLoader = manager.createAdLoader(forUnit: unit) else {
            return
        }

        self.adLoader = adLoader
        self.adLoader?.delegate = self

        let req = Request()
        self.adLoader?.load(req)
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        #if DEBUG
        print("NativeAd load failed: \(error)")
        #endif
        self.nativeAdContent = nil
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAdContent = NativeAdContent(nativeAd: nativeAd)
    }
}

struct NativeAdSwiftUIView<Content: View>: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    @State private var coordinator: NativeAdLoaderCoordinator
    private let contentBuilder: (NativeAdContent?) -> Content
    private let adUnit: SwiftUIAdManager.GADUnitName

    init(adUnit: SwiftUIAdManager.GADUnitName, @ViewBuilder content: @escaping (NativeAdContent?) -> Content) {
        self.adUnit = adUnit
        _coordinator = State(wrappedValue: NativeAdLoaderCoordinator())
        self.contentBuilder = content
    }

    var body: some View {
        ZStack(alignment: .center) {
            if let content = coordinator.nativeAdContent,
               let mediaContent = content.mediaContent {
                NativeAdRepresentable(mediaContent: mediaContent)
                    .task {
                        await adManager.requestAppTrackingIfNeed()
                    }
            }
            contentBuilder(coordinator.nativeAdContent)
                .allowsHitTesting(coordinator.nativeAdContent != nil ? false : true)
        }
        .onChange(of: adManager.isReady, initial: false) {
            guard adManager.isReady else { return }

            coordinator.load(withAdManager: adManager, forUnit: adUnit)
        }
        .task {
            guard adManager.isReady else { return }

            coordinator.load(withAdManager: adManager, forUnit: adUnit)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

private struct NativeAdRepresentable: UIViewRepresentable {
    let mediaContent: MediaContent

    func makeUIView(context: Context) -> MediaView {
        MediaView()
    }

    func updateUIView(_ uiView: MediaView, context: Context) {
        uiView.mediaContent = mediaContent
    }
}
