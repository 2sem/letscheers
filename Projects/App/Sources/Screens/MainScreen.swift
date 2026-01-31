//
//  MainScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var router = NavigationRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            CategoryGridScreen()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .toastList(let category, let title, let backgroundImage):
                        Text("Toast List - TODO")
                            .navigationTitle(title)
                    case .favorites:
                        Text("Favorites - TODO")
                            .navigationTitle("즐겨찾기")
                    }
                }
        }
        .environmentObject(router)
    }
}
