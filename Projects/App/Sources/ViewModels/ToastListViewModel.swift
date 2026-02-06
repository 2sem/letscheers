//
//  ToastListViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData
import Combine

@MainActor
class ToastListViewModel: ObservableObject {
    @Published var searchText: String = ""

    let categoryName: String
    private var cancellables = Set<AnyCancellable>()
    
    @Published var filteredToasts: [ToastViewModel] = []
    
    init(categoryName: String) {
        self.categoryName = categoryName

        // Update toasts when search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func refresh(toasts: [Toast]) {
        if searchText.isEmpty {
            filteredToasts = toasts.map{ ToastViewModel(toast: $0) }
        } else {
            filteredToasts = toasts.filter { $0.title.contains(searchText) }
                .map{ ToastViewModel(toast: $0) }
        }
    }
    
    func toggleFavorite(for toastViewModel: ToastViewModel, modelContext: ModelContext) {
        let newValue = !toastViewModel.isFavorite
        let _ = toastViewModel.id

        if newValue {
            let favorite = Favorite(toast: toastViewModel.toast)
            modelContext.insert(favorite)
            toastViewModel.toast.favorite = favorite
            try? modelContext.save()
        } else if let favorite = toastViewModel.toast.favorite {
            modelContext.delete(favorite)
            toastViewModel.toast.favorite = nil
            try? modelContext.save()
        }
    }

    func randomToast(modelContext: ModelContext) -> ToastViewModel? {
        // Query category and get random toast
        let descriptor = FetchDescriptor<ToastCategory>(
            predicate: #Predicate<ToastCategory> { category in
                category.name == categoryName
            }
        )
        
        guard let category = try? modelContext.fetch(descriptor).first,
              !category.toasts.isEmpty else {
            return nil
        }
        
        let randomToast = category.toasts.randomElement()!
        
        return ToastViewModel(toast: randomToast)
    }
}
