//
//  Toast.swift
//  letscheers
//
//  Created by Claude Code on 2026. 2. 1.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Toast {
    @Attribute(.unique) var no: Int16
    
    var title: String
    var contents: String

    var category: ToastCategory?
    
    @Relationship(deleteRule: .cascade, inverse: \Favorite.toast) var favorite: Favorite?

    init(no: Int16, title: String, contents: String, category: ToastCategory? = nil) {
        self.no = no
        self.title = title
        self.contents = contents
        self.category = category
    }
}
