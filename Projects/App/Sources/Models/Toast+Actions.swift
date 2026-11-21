//
//  Toast+Actions.swift
//  letscheers
//

import SwiftUI
import SwiftData

extension Toast {
    var isFavorite: Bool { favorite != nil }

    /// Adds or removes this toast's `Favorite` and saves.
    func toggleFavorite(in modelContext: ModelContext) {
        if let favorite {
            modelContext.delete(favorite)
            self.favorite = nil
        } else {
            let newFavorite = Favorite(toast: self)
            modelContext.insert(newFavorite)
            self.favorite = newFavorite
        }
        try? modelContext.save()
    }

    /// Plain-text form used for copy and the text-share fallback.
    var plainText: String {
        contents.isEmpty ? title : "\(title)\n\(contents)"
    }

    /// Text-share fallback message, including the App Store link.
    var shareText: String {
        "\(plainText)\n\n— 술마셔 건배사 \(AppLinks.appStore.absoluteString)"
    }

    /// Deterministic "오늘의 건배사" pick: stable for the whole day, no storage.
    static func toastOfTheDay(from toasts: [Toast], date: Date = .now, calendar: Calendar = .current) -> Toast? {
        guard !toasts.isEmpty else { return nil }
        let sorted = toasts.sorted { $0.no < $1.no }
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let year = calendar.component(.year, from: date)
        return sorted[(dayOfYear + year * 366) % sorted.count]
    }
}

enum AppLinks {
    static let appStore = URL(string: "https://apps.apple.com/app/id1193053041") ?? URL(fileURLWithPath: "/")
}
