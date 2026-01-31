//
//  CategoryViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct CategoryViewModel: Identifiable {
    enum CategoryType {
        case normal
        case ads
        case favorite
    }
    
    let id = UUID()
    let name: String?
    let title: String
    let type: CategoryType
    let icon: UIImage
    let background: UIImage?
    let count: Int
    
    init(name: String?, title: String, type: CategoryType, icon: UIImage, background: UIImage? = nil, count: Int = 0) {
        self.name = name
        self.title = title
        self.type = type
        self.icon = icon
        self.background = background
        self.count = count
    }
}
