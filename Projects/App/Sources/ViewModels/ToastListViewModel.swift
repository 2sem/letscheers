//
//  ToastListViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import Combine

@MainActor
class ToastListViewModel: ObservableObject {
    @Published var toasts: [ToastViewModel] = []
    @Published var searchText: String = ""
    
    private let category: String
    private let modelController = LCModelController.shared
    private var allToasts: [LCToast] = []
    private var cancellables = Set<AnyCancellable>()
    
    var filteredToasts: [ToastViewModel] {
        if searchText.isEmpty {
            return toasts
        } else {
            return toasts.filter { $0.title.contains(searchText) }
        }
    }
    
    init(category: String) {
        self.category = category
        loadToasts()
        
        // Update toasts when search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    private func loadToasts() {
        // Find category from Excel controller
        guard let currentCategory = LCExcelController.shared.categories.first(where: { $0.name == category }) else {
            return
        }
        
        allToasts = currentCategory.toasts
        
        // Convert to ViewModels with favorite status
        toasts = allToasts.map { toast in
            let isFavorite = modelController.isExistFavorite(withName: toast.title ?? "")
            return ToastViewModel(from: toast, isFavorite: isFavorite)
        }
    }
    
    func toggleFavorite(for toast: ToastViewModel) {
        guard let index = toasts.firstIndex(where: { $0.id == toast.id }) else {
            return
        }
        
        toasts[index].isFavorite.toggle()
        let newValue = toasts[index].isFavorite
        
        if newValue {
            // Add to favorites
            let favorite = modelController.createFavorite(name: toast.title, contents: toast.contents)
            favorite.category = category
        } else {
            // Remove from favorites
            if let existingFavorite = modelController.findFavorite(withName: toast.title).first {
                modelController.removeFavorite(toast: existingFavorite)
            }
        }
        
        modelController.saveChanges()
    }
    
    func randomToast() -> ToastViewModel? {
        let toast = LCExcelController.shared.randomToast(category)
        let isFavorite = modelController.isExistFavorite(withName: toast.title ?? "")
        return ToastViewModel(from: toast, isFavorite: isFavorite)
    }
}
