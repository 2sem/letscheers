//
//  RandomToastHeroView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The centered title + meaning + optional category chip.
/// Carries `.id(toast.persistentModelID)` so a re-roll animates as a transition.
struct RandomToastHeroView: View {
    let toast: Toast
    let showCategoryChip: Bool
    @Binding var isExpanded: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var meaningLineLimit: Int? { isExpanded ? nil : 4 }

    var body: some View {
        VStack(spacing: 16) {
            Text(toast.title)
                .font(.title)
                .bold()
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .tracking(0.5)

            if !toast.contents.isEmpty {
                Text(toast.contents)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(meaningLineLimit)
            }

            if showCategoryChip, let name = toast.category?.name {
                Text(name)
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.iconContainer))
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.smooth(duration: 0.28)) {
                isExpanded.toggle()
            }
        }
        .id(toast.persistentModelID)
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.97)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("랜덤 건배사")
        .accessibilityValue(accessibilityValue)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("두 번 누르면 뜻을 모두 펼쳐요")
    }

    private var accessibilityValue: String {
        var parts: [String] = [toast.title]
        if !toast.contents.isEmpty { parts.append("뜻, \(toast.contents)") }
        if let name = toast.category?.name { parts.append("카테고리, \(name)") }
        return parts.joined(separator: ". ")
    }
}
