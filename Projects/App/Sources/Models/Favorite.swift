//
//  Favorite.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import SwiftData

@Model
final class Favorite {
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var toast: Toast

    init(toast: Toast, createdAt: Date = Date()) {
        self.toast = toast
        self.createdAt = createdAt
    }
}
