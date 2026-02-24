//
//  ToastsManager.swift
//  letscheers
//
//  Created by Claude Code on 2026. 2. 1.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import SwiftData

@MainActor
class ToastsManager: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Categories

    func allCategories() -> [ToastCategory] {
        let descriptor = FetchDescriptor<ToastCategory>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func category(named name: String) -> ToastCategory? {
        let descriptor = FetchDescriptor<ToastCategory>(
            predicate: #Predicate { $0.name == name }
        )
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Toasts

    func toasts(inToastCategory categoryName: String) -> [Toast] {
        let descriptor = FetchDescriptor<Toast>(
            predicate: #Predicate { $0.category?.name == categoryName },
            sortBy: [SortDescriptor(\.title, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func toast(withTitle title: String) -> Toast? {
        let descriptor = FetchDescriptor<Toast>(
            predicate: #Predicate { $0.title == title }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func randomToast(inToastCategory categoryName: String) -> Toast? {
        let toasts = toasts(inToastCategory: categoryName)
        return toasts.randomElement()
    }

    func randomToast() -> Toast? {
        let descriptor = FetchDescriptor<Toast>()
        let toasts = (try? modelContext.fetch(descriptor)) ?? []
        return toasts.randomElement()
    }

    func searchToasts(query: String, inToastCategory categoryName: String? = nil) -> [Toast] {
        let descriptor: FetchDescriptor<Toast>

        if let categoryName = categoryName {
            descriptor = FetchDescriptor<Toast>(
                predicate: #Predicate { toast in
                    toast.category?.name == categoryName &&
                    (toast.title.localizedStandardContains(query) ||
                     toast.contents.localizedStandardContains(query))
                }
            )
        } else {
            descriptor = FetchDescriptor<Toast>(
                predicate: #Predicate { toast in
                    toast.title.localizedStandardContains(query) ||
                    toast.contents.localizedStandardContains(query)
                }
            )
        }

        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
