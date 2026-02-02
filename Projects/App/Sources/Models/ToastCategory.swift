//
//  ToastCategory.swift
//  letscheers
//
//  Created by Claude Code on 2026. 2. 1.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class ToastCategory {
    var name: String
    var title: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Toast.category)
    var toasts: [Toast] = []

    init(name: String, title: String, sortOrder: Int = 0) {
        self.name = name
        self.title = title
        self.sortOrder = sortOrder
    }
}
