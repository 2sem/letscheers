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
    @EnvironmentObject private var randomCoordinator: RandomToastCoordinator

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeScreen()
                .navigationDestination(for: NavigationDestination.self) { destination in
                    switch destination {
                    case .toastList(let category, let title):
                        ToastListScreen(
                            title: title,
                            viewModel: ToastListViewModel(categoryName: category)
                        )
                    case .favorites:
                        FavoritesScreen()
                    case .toastDetail(let toastNos, let index):
                        ToastDetailRoute(toastNos: toastNos, index: index)
                    }
                }
        }
        .overlay {
            if randomCoordinator.isPresentingAd {
                RandomAdWaitingOverlay()
            }
        }
        .sheet(item: $randomCoordinator.presentedPrompt) { flow in
            RandomToastSheet(flow: flow)
        }
        .sheet(item: $randomCoordinator.presentedResult, onDismiss: pushPendingDetail) { flow in
            RandomToastSheet(flow: flow)
        }
        .sheet(item: $randomCoordinator.presentedEmpty) { presentation in
            RandomToastEmptyView(error: presentation.error) {
                randomCoordinator.close()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.cardBackground)
            .presentationCornerRadius(24)
            .onDisappear {
                randomCoordinator.close()
            }
        }
        // Outermost on purpose: sheets inherit the environment of the view they
        // are attached to, so `router` must be injected after every `.sheet`.
        .environmentObject(router)
    }

    /// Pushes the read-aloud detail requested from the result sheet, once the
    /// sheet is fully gone (pushing mid-dismissal is unreliable).
    private func pushPendingDetail() {
        guard let toast = randomCoordinator.consumePendingDetail() else { return }
        router.openDetail(of: [toast], at: 0)
    }
}
