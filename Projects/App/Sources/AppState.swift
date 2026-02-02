//
//  AppState.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

@MainActor
class AppState: ObservableObject {
    @Published var isInitialized = false

    let excelController = LCExcelController.shared
    let swiftDataContainer: ModelContainer
    let favoritesManager: FavoritesManager
    let toastsManager: ToastsManager

    init() {
        let schema = Schema([
            Favorite.self,
            Toast.self,
            ToastCategory.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            self.swiftDataContainer = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )

            // Create shared managers with same ModelContext
            let modelContext = ModelContext(swiftDataContainer)
            self.favoritesManager = FavoritesManager(modelContext: modelContext)
            self.toastsManager = ToastsManager(modelContext: modelContext)
        } catch {
            fatalError("Failed to create Swift Data container: \(error)")
        }
    }
}
