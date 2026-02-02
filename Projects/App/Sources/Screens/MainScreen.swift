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
                    case .toastList(let category, let title, let backgroundImageName):
                        let backgroundImage = backgroundImageName != nil ? UIImage(named: backgroundImageName!) : nil
                        ToastListScreen(
                            title: title,
                            backgroundImage: backgroundImage,
                            viewModel: ToastListViewModel(categoryName: category)
                        )
                    case .favorites:
                        FavoritesScreen()
                    }
                }
        }
        .environmentObject(router)
    }
}
