//
//  NativeAdSwiftUIView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

@Observable
final class NativeAdLoaderCoordinator: NSObject, ObservableObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    var nativeAd: NativeAd?
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
        self.nativeAd = nil
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
    }
}

struct NativeAdSwiftUIView<Content: View>: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    @State private var coordinator: NativeAdLoaderCoordinator
    private let contentBuilder: (NativeAd?) -> Content
    private let adUnit: SwiftUIAdManager.GADUnitName

    init(adUnit: SwiftUIAdManager.GADUnitName, @ViewBuilder content: @escaping (NativeAd?) -> Content) {
        self.adUnit = adUnit
        _coordinator = State(wrappedValue: NativeAdLoaderCoordinator())
        self.contentBuilder = content
    }

    var body: some View {
        ZStack(alignment: .center) {
            if let ad = coordinator.nativeAd {
                NativeAdRepresentable(nativeAd: ad)
            }
            contentBuilder(coordinator.nativeAd)
                .allowsHitTesting(coordinator.nativeAd != nil ? false : true)
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
    let nativeAd: NativeAd
    let headlineView = UILabel()

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()
        adView.headlineView = self.headlineView
        return adView
    }

    func updateUIView(_ uiView: NativeAdView, context: Context) {
        uiView.nativeAd = nativeAd
        uiView.adChoicesView = .init()
        if let advertiser = uiView.advertiserView as? UILabel {
            advertiser.text = nativeAd.advertiser
            uiView.advertiserView?.isHidden = nativeAd.advertiser == nil
        }
    }
}
