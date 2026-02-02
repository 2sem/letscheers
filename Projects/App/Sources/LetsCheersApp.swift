//
//  LetsCheersApp.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import Firebase
import GoogleMobileAds

@main
struct LetsCheersApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var appState = AppState()
    @StateObject private var adManager = SwiftUIAdManager()

    @State private var isSetupDone = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isInitialized {
                    MainScreen()
                        .environmentObject(appState)
                        .environmentObject(adManager)
                        .environmentObject(appState.favoritesManager)
                        .environmentObject(appState.toastsManager)
                        .modelContainer(appState.swiftDataContainer)
                } else {
                    SplashScreen(appState: appState)
                        .modelContainer(appState.swiftDataContainer)
                }
            }
            .onAppear {
                setupAds()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }

    private func setupAds() {
        guard !isSetupDone else {
            return
        }

        FirebaseApp.configure()

        MobileAds.shared.start { [weak adManager] status in
            guard let adManager = adManager else { return }

            adManager.setup()

            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["8a00796a760e384800262e0b7c3d08fe"]

            #if DEBUG
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            adManager.prepare(openingUnit: .launch, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0 * 60)
            adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
            #endif
            adManager.canShowFirstTime = true
        }

        isSetupDone = true
    }

    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            handleAppDidBecomeActive()
        case .inactive:
            break
        case .background:
            break
        @unknown default:
            break
        }
    }

    private func handleAppDidBecomeActive() {
        print("scene become active")
        Task {
            defer {
                LSDefaults.increaseLaunchCount()
            }

            await adManager.show(unit: .launch)
        }
    }
}
