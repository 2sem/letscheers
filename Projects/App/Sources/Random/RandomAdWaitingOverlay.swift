//
//  RandomAdWaitingOverlay.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 3.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// Root-level wait scrim shown while `adManager.show(.full)` is in flight.
///
/// The random sheet is fully dismissed during the ad call (the interstitial
/// needs the root view controller), so the indicator can't live in a sheet.
/// It delays ~150ms before appearing so the no-ad fast path never flashes it —
/// on that path the coordinator clears `isPresentingAd` before the timer fires.
struct RandomAdWaitingOverlay: View {
    @State private var visible = false

    var body: some View {
        ZStack {
            if visible {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color.accentPurple)

                    Text("건배사 뽑는 중…")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                }
                .padding(28)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.cardBackground))
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("건배사를 뽑고 있어요")
        .task {
            try? await Task.sleep(for: .seconds(0.15))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.2)) { visible = true }
            UIAccessibility.post(notification: .announcement, argument: "건배사를 뽑고 있어요")
        }
    }
}
