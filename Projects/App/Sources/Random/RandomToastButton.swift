//
//  RandomToastButton.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The single nav control that opens the random-toast surface.
///
/// - `.capsule`: home grid — an `accentPurple` tinted capsule (`shuffle` + "랜덤").
/// - `.icon`: category list — a plain scoped `shuffle` glyph.
///
/// Both open the identical `RandomToastSheet`; the only difference is `pool`.
struct RandomToastButton: View {
    enum Style {
        case icon
        case capsule
    }

    let style: Style
    /// `nil` disables the control (e.g. a category id could not be resolved).
    let pool: RandomPool?

    @EnvironmentObject private var coordinator: RandomToastCoordinator
    @Environment(\.modelContext) private var modelContext

    private var isRolling: Bool { coordinator.state != .idle }

    var body: some View {
        Button {
            guard let pool else { return }
            coordinator.start(pool: pool, modelContext: modelContext)
        } label: {
            label
        }
        .disabled(pool == nil || isRolling)
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: coordinator.rollCount)
        .accessibilityLabel("랜덤 건배사")
        .accessibilityHint("무작위로 건배사를 하나 골라 보여줍니다")
        .accessibilityValue(isRolling ? "사용할 수 없음" : "")
    }

    @ViewBuilder
    private var label: some View {
        switch style {
        case .icon:
            glyph
                .font(.body)
                .foregroundStyle(Color.primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())

        case .capsule:
            HStack(spacing: 6) {
                glyph
                Text("랜덤")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(Color.primary)
            .fixedSize()
        }
    }

    /// One `.bounce` per 랜덤 tap. The roll window is ~0.15s, so a single
    /// bounce reads better than a looping spin; Reduce Motion is handled by the
    /// system for `symbolEffect`.
    private var glyph: some View {
        Image(systemName: "shuffle")
    }
}
