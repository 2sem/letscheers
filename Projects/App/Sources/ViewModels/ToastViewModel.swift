//
//  ToastViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation

struct ToastViewModel: Identifiable {
    let id = UUID()
    let title: String
    let contents: String
    let category: String
    var isFavorite: Bool
    
    init(from toast: LCToast, isFavorite: Bool = false) {
        self.title = toast.title ?? ""
        self.contents = toast.contents ?? ""
        self.category = toast.category ?? ""
        self.isFavorite = isFavorite
    }
}
