//
//  RollingShuffleIcon.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// Non-interactive spinner shown in place of the shuffle nav control while a
/// roll is in flight. Respects Reduce Motion (dims instead of spinning).
struct RollingShuffleIcon: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spinning = false

    var body: some View {
        Image(systemName: "shuffle")
            .rotationEffect(.degrees(spinning && !reduceMotion ? 360 : 0))
            .opacity(reduceMotion ? 0.4 : 1)
            .animation(
                reduceMotion ? nil : .linear(duration: 0.6).repeatForever(autoreverses: false),
                value: spinning
            )
            .onAppear { spinning = true }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
