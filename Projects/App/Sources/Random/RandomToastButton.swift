//
//  RandomToastButton.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

/// The single nav control that opens the random-toast surface.
///
/// - `.capsule`: home grid — an `accentPurple` tinted capsule (`shuffle` + "랜덤").
/// - `.icon`: category list — a plain scoped `shuffle` glyph.
///
/// - `.hero`: home — full-width gold CTA (`dice.fill`, title + subtitle).
/// - `.goldPill`: compact gold capsule for empty states.
///
/// All open the identical `RandomToastSheet`; the only difference is `pool`.
struct RandomToastButton: View {
    enum Style {
        case icon
        case capsule
        case hero
        case goldPill
    }

    let style: Style
    /// `nil` disables the control (e.g. a category id could not be resolved).
    let pool: RandomPool?

    @EnvironmentObject private var coordinator: RandomToastCoordinator
    @Environment(\.modelContext) private var modelContext

    private var isRolling: Bool { coordinator.state != .idle }

    var body: some View {
        styledButton
        .disabled(pool == nil || isRolling)
        .sensoryFeedback(.impact(weight: .medium, intensity: 0.7), trigger: coordinator.rollCount)
        .accessibilityLabel(style == .hero ? "랜덤 건배사 뽑기" : "랜덤 건배사")
        .accessibilityHint(style == .hero ? "무작위 건배사를 하나 보여줍니다" : "무작위로 건배사를 하나 골라 보여줍니다")
        .accessibilityValue(isRolling ? "사용할 수 없음" : "")
    }

    private var button: some View {
        Button {
            guard let pool else { return }
            coordinator.start(pool: pool, modelContext: modelContext)
        } label: {
            label
        }
    }

    @ViewBuilder
    private var styledButton: some View {
        switch style {
        case .hero, .goldPill:
            button.buttonStyle(PressScaleButtonStyle())
        case .icon, .capsule:
            button
        }
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

        case .hero:
            heroLabel

        case .goldPill:
            Text("랜덤 건배사")
                .font(.headline)
                .foregroundStyle(Color.onGold)
                .padding(.horizontal, 20)
                .frame(minHeight: 44)
                .background(Capsule().fill(Color.accentGold))

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

    // MARK: Hero

    private var heroLabel: some View {
        HStack(spacing: 16) {
            Image(systemName: "dice.fill")
                .font(.system(size: 32, weight: .semibold))
                .symbolEffect(.bounce, value: coordinator.rollCount)

            VStack(alignment: .leading, spacing: 4) {
                Text("지금 바로 랜덤 건배사")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.leading)
                Text("갑자기 건배사 차례가 왔다면?")
                    .font(.subheadline)
                    .opacity(0.8)
            }

            Spacer(minLength: 0)
        }
        .foregroundStyle(Color.onGold)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .background {
            ZStack(alignment: .trailing) {
                Color.accentGold
                Image("bg_cheers")
                    .resizable()
                    .scaledToFit()
                    .opacity(0.2)
                    .frame(maxHeight: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .contentShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// MARK: - Press Style

/// Plain button that springs to 0.98 while pressed (Reduce Motion: none).
struct PressScaleButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .animation(.spring(duration: 0.25), value: configuration.isPressed)
    }
}
