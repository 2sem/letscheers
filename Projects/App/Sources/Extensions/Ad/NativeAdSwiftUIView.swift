//
//  NativeAdSwiftUIView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

//
//  NativeAdSwiftUIView.swift
//  App
//
//  Native ad container view for SwiftUI
//

//
//  NativeAdRowView.swift
//  sendadv
//
//  Created by Assistant on 2025/08/26.
//

import SwiftUI
import GoogleMobileAds

// Info.plist에서 네이티브 광고 단위 ID 읽기

@Observable
final class NativeAdLoaderCoordinator: NSObject, ObservableObject, AdLoaderDelegate, NativeAdLoaderDelegate {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed
    }

    var nativeAd: NativeAd?
    private(set) var loadState: LoadState = .idle
    private var adLoader: AdLoader?

    /// Fire-once per instance. Repeated calls (e.g. `.task` + `.onChange`) are ignored
    /// so a row that scrolls in and out of view never re-requests an ad.
    func load(withAdManager manager: SwiftUIAdManager, forUnit unit: SwiftUIAdManager.GADUnitName) {
        guard loadState == .idle else { return }

        guard let adLoader = manager.createAdLoader(forUnit: unit) else {
            loadState = .failed
            return
        }

        loadState = .loading
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
        self.loadState = .failed
    }

    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        self.loadState = .loaded
    }
}

struct NativeAdSwiftUIView<Content: View>: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager

    @State private var coordinator: NativeAdLoaderCoordinator
    private let contentBuilder: (NativeAd?) -> Content
    private let adUnit: SwiftUIAdManager.GADUnitName
    private let onLoadStateChange: ((NativeAdLoaderCoordinator.LoadState) -> Void)?
    @State var shouldLoadAd: Bool

    init(
        adUnit: SwiftUIAdManager.GADUnitName,
        shouldLoadAd: Bool,
        onLoadStateChange: ((NativeAdLoaderCoordinator.LoadState) -> Void)? = nil,
        @ViewBuilder content: @escaping (NativeAd?) -> Content
    ) {
        self.adUnit = adUnit
        _coordinator = State(wrappedValue: NativeAdLoaderCoordinator())
        self.contentBuilder = content
        self.onLoadStateChange = onLoadStateChange
        self.shouldLoadAd = shouldLoadAd
    }

    var body: some View {
        ZStack(alignment: .center) {
            if let ad = coordinator.nativeAd {
                NativeAdRepresentable(nativeAd: ad)
            }
            contentBuilder(coordinator.nativeAd)
                .allowsHitTesting(coordinator.nativeAd != nil ? false : true)
        }
        .onChange(of: coordinator.loadState, initial: true) { _, newValue in
            onLoadStateChange?(newValue)
        }
        .onChange(of: adManager.isReady, initial: false) {
            guard adManager.isReady, shouldLoadAd else { return }

            coordinator.load(withAdManager: adManager, forUnit: adUnit)
        }
        .task {
            guard adManager.isReady, shouldLoadAd else { return }
            
            coordinator.load(withAdManager: adManager, forUnit: adUnit)
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
    }
}

// Developer placeholder 제거됨. 상위 View에서 nil 상태를 표현하세요.

private struct NativeAdRepresentable: UIViewRepresentable {
    let nativeAd: NativeAd
    let headlineView = UILabel()

    func makeUIView(context: Context) -> NativeAdView {
        let adView = NativeAdView()
//        adView.advertiserView = .init()
        adView.headlineView = self.headlineView
        // configureSubviews(for: adView)
        return adView
    }

    func updateUIView(_ uiView: NativeAdView, context: Context) {
        uiView.nativeAd = nativeAd
        uiView.adChoicesView = .init()
//        if let headline = uiView.headlineView as? UILabel {
//            headline.text = nativeAd.headline
//        }
//        if let body = uiView.bodyView as? UILabel {
//            body.text = nativeAd.body
//            uiView.bodyView?.isHidden = nativeAd.body == nil
//        }
        if let advertiser = uiView.advertiserView as? UILabel {
            advertiser.text = nativeAd.advertiser
            uiView.advertiserView?.isHidden = nativeAd.advertiser == nil
        }
//        if let icon = uiView.iconView as? UIImageView {
//            icon.image = nativeAd.icon?.image
//            uiView.iconView?.isHidden = nativeAd.icon == nil
//        }
//        if let cta = uiView.callToActionView as? UIButton {
//            cta.setTitle(nativeAd.callToAction, for: .normal)
//            uiView.callToActionView?.isHidden = nativeAd.callToAction == nil
//        }
    }

    private func configureSubviews(for adView: NativeAdView) {
        let container = UIStackView()
        container.axis = .horizontal
        container.alignment = .center
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 8
        iconView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4
        textStack.translatesAutoresizingMaskIntoConstraints = false

        let headline = UILabel()
        headline.font = .preferredFont(forTextStyle: .headline)

        let body = UILabel()
        body.font = .preferredFont(forTextStyle: .subheadline)
        body.textColor = .secondaryLabel
        body.numberOfLines = 2

        let advertiser = UILabel()
        advertiser.font = .preferredFont(forTextStyle: .caption1)
        advertiser.textColor = .tertiaryLabel

        let cta = UIButton(type: .system)
        cta.setTitle("ads action".localized(), for: .normal)
        cta.configuration = .tinted()

        textStack.addArrangedSubview(headline)
        textStack.addArrangedSubview(body)
        textStack.addArrangedSubview(advertiser)

        container.addArrangedSubview(iconView)
        container.addArrangedSubview(textStack)
        container.addArrangedSubview(cta)

        adView.addSubview(container)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            container.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            container.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
            container.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12)
        ])

        adView.iconView = iconView
        adView.headlineView = headline
        adView.bodyView = body
        adView.advertiserView = advertiser
        adView.callToActionView = cta
    }
}
