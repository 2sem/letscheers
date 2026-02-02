//
//  ToastViewModel.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation


struct ToastViewModel: Identifiable {
    var id: Int16
    
    let toast: Toast
    var isFavorite: Bool {
        return toast.favorite != nil
    }
    
    init(toast: Toast) {
        self.id = toast.no
        self.toast = toast
    }
}
