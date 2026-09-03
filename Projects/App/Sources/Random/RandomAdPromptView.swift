//
//  RandomAdPromptView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 3.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The up-front opt-in prompt shown on every 랜덤 tap before a toast is revealed.
///
/// Purely presentational: the sheet owns the ad orchestration and drives the
/// phase machine via the two closures.
struct RandomAdPromptView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAccepting = false
    @AccessibilityFocusState private var titleFocused: Bool

    private var isAccessibilitySize: Bool { dynamicTypeSize >= .accessibility1 }

    var body: some View {
        VStack(spacing: 0) {
            if isAccessibilitySize {
                ScrollView { copyBlock.padding(.top, 8) }
            } else {
                copyBlock
                    .padding(.top, 8)
                Spacer(minLength: 8)
            }

            buttons
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAddTraits(.isModal)
        .onAppear {
            if !reduceMotion {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { titleFocused = true }
            } else {
                titleFocused = true
            }
        }
    }

    // MARK: Copy

    private var copyBlock: some View {
        VStack(spacing: 20) {
            if !isAccessibilitySize {
                iconCircle
            }

            Text("광고 보고 건배사 뽑기")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
                .accessibilityFocused($titleFocused)

            Text("짧은 광고를 본 뒤 무작위 건배사를 하나 뽑아드려요.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("카테고리에서 직접 고르기는 광고 없이 이용할 수 있어요.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var iconCircle: some View {
        ZStack {
            Circle()
                .fill(Color.accentPurple.opacity(0.12))
            Image(systemName: "shuffle")
                .font(.title2)
                .foregroundStyle(Color.accentPurple)
        }
        .frame(width: 56, height: 56)
        .accessibilityHidden(true)
    }

    // MARK: Buttons

    private var buttons: some View {
        VStack(spacing: 8) {
            Button {
                guard !isAccepting else { return }
                isAccepting = true
                onAccept()
            } label: {
                if isAccepting {
                    ProgressView()
                        .tint(Color.navBar)
                } else {
                    Text("광고 보고 뽑기")
                }
            }
            .buttonStyle(RandomPrimaryButtonStyle())
            .disabled(isAccepting)
            .accessibilityLabel("광고 보고 건배사 뽑기")
            .accessibilityHint("광고를 본 후 무작위 건배사를 보여줍니다.")

            Button {
                onDecline()
            } label: {
                Text("취소")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(isAccepting)
            .accessibilityLabel("취소")
        }
    }
}
