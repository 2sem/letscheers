//
//  RandomPrimaryButtonStyle.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The "다시 뽑기" primary capsule: `accentPurple` fill, 50pt tall, r16,
/// soft purple shadow. Label uses `Color.navBar` (the dark-purple token) —
/// matches the shipped 랜덤 capsule and clears AA (~8:1) on the lavender
/// dark-mode `accentPurple` fill, where white would fail (~2:1).
struct RandomPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.navBar)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentPurple))
            .shadow(color: Color.accentPurple.opacity(0.35), radius: 12, x: 0, y: 4)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.15), value: configuration.isPressed)
    }
}
