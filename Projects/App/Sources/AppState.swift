//
//  AppState.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var isInitialized = false
    
    let excelController = LCExcelController.shared
    let modelController = LCModelController.shared
}
