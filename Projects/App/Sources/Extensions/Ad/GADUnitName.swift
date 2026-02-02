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
        case launch = "ca-app-pub-9684378399371172/4877474273"
        case full = "ca-app-pub-9684378399371172/4931504044"
        case native = "ca-app-pub-9684378399371172/1903064527"
    }

#if DEBUG
    var testUnits: [GADUnitName] {
        [.launch, .full, .native]
    }
#else
    var testUnits: [GADUnitName] { [] }
#endif
}
