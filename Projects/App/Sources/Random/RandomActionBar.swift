//
//  RandomActionBar.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// Pinned action row: favorite · "다시 뽑기" · share.
/// Reflows to a vertical stack at accessibility Dynamic Type sizes.
struct RandomActionBar: View {
    let toast: Toast
    let poolCount: Int
    let isRerollLocked: Bool
    let onReroll: () -> Void
    let onToggleFavorite: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var isFavorite: Bool { toast.favorite != nil }
    private var canReroll: Bool { poolCount > 1 }

    private var shareText: String {
        "\(toast.title)\n\n\(toast.contents)\n\n— 술마셔 건배사"
    }

    var body: some View {
        VStack(spacing: 8) {
            if dynamicTypeSize >= .accessibility1 {
                VStack(spacing: 12) {
                    rerollButton
                    HStack(spacing: 12) {
                        favoriteButton
                        shareButton
                    }
                }
            } else {
                HStack(spacing: 12) {
                    favoriteButton
                    rerollButton
                    shareButton
                }
            }

            if !canReroll {
                Text("이 카테고리엔 건배사가 하나뿐이에요")
                    .font(.caption)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .sensoryFeedback(trigger: isFavorite) { _, now in
            now ? .success : .selection
        }
    }

    // MARK: Favorite

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.accentPurple : Color.primary)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.iconContainer))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("즐겨찾기")
        .accessibilityValue(isFavorite ? "추가됨" : "추가 안 됨")
        .accessibilityAddTraits(isFavorite ? [.isSelected] : [])
    }

    // MARK: Re-roll

    private var rerollButton: some View {
        Button {
            onReroll()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "shuffle")
                Text("다시 뽑기")
            }
        }
        .buttonStyle(RandomPrimaryButtonStyle())
        .disabled(!canReroll || isRerollLocked)
        .opacity(canReroll ? 1 : 0.4)
        .accessibilityLabel("다시 뽑기")
        .accessibilityHint("다른 건배사를 무작위로 다시 고릅니다")
        .accessibilityValue(canReroll ? "" : "사용할 수 없음")
    }

    // MARK: Share

    private var shareButton: some View {
        ShareLink(item: shareText) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .foregroundStyle(Color.primary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.iconContainer))
                .contentShape(Circle())
        }
        .accessibilityLabel("공유")
    }
}
