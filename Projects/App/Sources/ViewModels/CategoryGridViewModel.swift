//
//  CategoryGridViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

@MainActor
class CategoryGridViewModel: ObservableObject {
    @Published var categories: [CategoryViewModel] = []
    
    func loadCategories(modelContext: ModelContext) {
        // Define the category configurations
        let categoryConfigs: [(name: String, title: String, icon: String, background: String)] = [
            ("선창!후창~!", "선/후창 건배사", "sing", "bg_follow.jpg"),
            ("모임", "모임용 건배사", "metting", "bg_meeting.jpg"),
            ("회식", "회식용 건배사", "dining", "bg_dining.jpg"),
            ("건강", "건강기원 건배사", "health", "bg_health.jpg")
        ]
        
        // Fetch all categories from Swift Data once
        let descriptor = FetchDescriptor<ToastCategory>()
        let allCategories = (try? modelContext.fetch(descriptor)) ?? []
        
        // Create lookup dictionary by name
        let categoryLookup = Dictionary(uniqueKeysWithValues: allCategories.map { ($0.name, $0) })
        
        // Map to view models
        var viewModels: [CategoryViewModel] = []
        
        for config in categoryConfigs {
            let toastCount = categoryLookup[config.name]?.toasts.count ?? 0
            
            viewModels.append(CategoryViewModel(
                name: config.name,
                title: config.title,
                type: .normal,
                icon: UIImage(named: config.icon) ?? UIImage(),
                background: UIImage(named: config.background),
                count: toastCount
            ))
        }
        
        // Add special categories
        viewModels.append(CategoryViewModel(
            name: "ads",
            title: "광고",
            type: .ads,
            icon: UIImage(named: "health") ?? UIImage(),
            background: nil,
            count: 0
        ))
        
        // Query favorites count from Swift Data
        let favoritesDescriptor = FetchDescriptor<Favorite>()
        let favoritesCount = (try? modelContext.fetchCount(favoritesDescriptor)) ?? 0
        
        viewModels.append(CategoryViewModel(
            name: "favorite",
            title: "즐겨찾기",
            type: .favorite,
            icon: UIImage(named: "health") ?? UIImage(),
            background: nil,
            count: favoritesCount
        ))
        
        categories = viewModels
    }
}
