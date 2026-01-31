//
//  CategoryGridViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import Combine

@MainActor
class CategoryGridViewModel: ObservableObject {
    @Published var categories: [CategoryViewModel] = []
    
    init() {
        loadCategories()
    }
    
    private func loadCategories() {
        // Create LCCategory objects matching UIKit version
        var lcCategories: [LCCategory] = []
        
        lcCategories.append(.init(
            name: "선창!후창~!",
            title: "선/후창 건배사",
            type: .normal,
            image: UIImage(named: "sing") ?? UIImage(),
            background: UIImage(named: "bg_follow.jpg")
        ))
        lcCategories.append(.init(
            name: "모임",
            title: "모임용 건배사",
            type: .normal,
            image: UIImage(named: "metting") ?? UIImage(),
            background: UIImage(named: "bg_meeting.jpg")
        ))
        lcCategories.append(.init(
            name: "회식",
            title: "회식용 건배사",
            type: .normal,
            image: UIImage(named: "dining") ?? UIImage(),
            background: UIImage(named: "bg_dining.jpg")
        ))
        lcCategories.append(.init(
            name: "건강",
            title: "건강기원 건배사",
            type: .normal,
            image: UIImage(named: "health") ?? UIImage(),
            background: UIImage(named: "bg_health.jpg")
        ))
        lcCategories.append(.init(
            name: "ads",
            title: "광고",
            type: .ads,
            image: UIImage(named: "health") ?? UIImage()
        ))
        lcCategories.append(.init(
            name: "favorite",
            title: "즐겨찾기",
            type: .favorite,
            image: UIImage(named: "health") ?? UIImage()
        ))
        
        // Load Excel data FIRST before reading counts
        let excelCategories = lcCategories.compactMap { $0.data as? LCToastCategory }
        LCExcelController.shared.categories = excelCategories
        LCExcelController.shared.loadCategories(categories: excelCategories)
        
        if let first = excelCategories.first {
            LCExcelController.shared.loadFollowToasts(withCategory: first)
        }
        
        // NOW convert to ViewModels with correct counts
        categories = lcCategories.map { category in
            CategoryViewModel(
                name: category.name,
                title: category.title,
                type: category.type == .normal ? .normal : (category.type == .ads ? .ads : .favorite),
                icon: category.image,
                background: category.background,
                count: category.count
            )
        }
    }
}
