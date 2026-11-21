//
//  RandomPrimaryButtonStyle.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The gold primary button ("다시 뽑기", "광고 보고 뽑기"): `accentGold` fill,
/// `onGold` label (> 10:1), 52pt tall, r16.
struct RandomPrimaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(Color.onGold)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color.accentGold))
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(duration: 0.15), value: configuration.isPressed)
    }
}
