//
//  FavoritesManager.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import SwiftData

@MainActor
class FavoritesManager: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func isExist(toastTitle: String) -> Bool {
        let descriptor = FetchDescriptor<Favorite>(
            predicate: #Predicate { $0.toast.title == toastTitle }
        )
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count > 0
    }

    func find(toastTitle: String) -> [Favorite] {
        let descriptor = FetchDescriptor<Favorite>(
            predicate: #Predicate { $0.toast.title == toastTitle }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    @discardableResult
    func create(toast: Toast) -> Favorite {
        let favorite = Favorite(toast: toast)
        modelContext.insert(favorite)
        save()
        return favorite
    }

    func remove(_ favorite: Favorite) {
        print("Removing favorite: \(favorite.toast.title)")
        print("Favorite ID: \(favorite.persistentModelID)")
        modelContext.delete(favorite)
        do {
            try modelContext.save()
            print("Successfully removed favorite")
        } catch {
            print("Failed to save after removing favorite: \(error)")
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorites: \(error)")
        }
    }
}
