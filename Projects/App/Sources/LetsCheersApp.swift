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
    @StateObject private var appState = AppState()
    
    init() {
        FirebaseApp.configure()
        GoogleMobileAds.MobileAds.shared.start(completionHandler: nil)
        LSDefaults.increaseLaunchCount()
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.isInitialized {
                Text("Main View - TODO")
                    .environmentObject(appState)
            } else {
                SplashScreen(appState: appState)
            }
        }
    }
}
