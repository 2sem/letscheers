//
//  RandomToastEmptyView.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// Shown inside the random surface when the pool can't produce a toast.
struct RandomToastEmptyView: View {
    let error: RandomError
    let onClose: () -> Void

    private var title: String {
        switch error {
        case .emptyDatabase: return "건배사를 불러오지 못했어요"
        case .emptyPool:      return "이 카테고리엔 아직 건배사가 없어요"
        }
    }

    private var message: String {
        switch error {
        case .emptyDatabase: return "앱을 다시 실행해 주세요."
        case .emptyPool:      return "다른 카테고리에서 뽑아 보세요."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 8)

            VStack(spacing: 16) {
                Image(systemName: "wineglass")
                    .font(.largeTitle)
                    .foregroundStyle(Color.secondary)

                Text(title)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            .accessibilityElement(children: .combine)

            Spacer(minLength: 8)

            Button("닫기", action: onClose)
                .font(.headline)
                .foregroundStyle(Color.accentPurple)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cardBackground)
        .onAppear {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}
