//
//  RandomLoadingView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 3.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// The brief "picking / ad on the way" phase between the prompt and the reveal.
///
/// Since availability is no longer known up front, the caption is shown for the
/// whole phase — if `show(.full)` fast-falls, the phase is short enough that the
/// caption never lingers misleadingly.
struct RandomLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(Color.accentPurple)

            Text("건배사 뽑는 중…")
                .font(.headline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("잠시 후 광고가 표시돼요")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("건배사를 뽑고 있어요")
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: "건배사를 뽑고 있어요")
        }
    }
}
