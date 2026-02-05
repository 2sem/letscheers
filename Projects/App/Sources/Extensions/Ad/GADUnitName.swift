//
//  GADUnitName.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation

extension SwiftUIAdManager {
    enum GADUnitName: String {
        case launch = "Launch"
        case full = "FullAd"
        case native = "NativeAd"
    }

#if DEBUG
    var testUnits: [GADUnitName] {
        [.launch, .full, .native]
    }
#else
    var testUnits: [GADUnitName] { [] }
#endif
}
