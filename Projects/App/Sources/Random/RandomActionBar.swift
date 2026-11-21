//
//  RandomActionBar.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

/// Pinned actions: gold "다시 뽑기", "낭독 모드", favorite star, share.
/// Reflows to a vertical stack at accessibility Dynamic Type sizes.
struct RandomActionBar: View {
    let toast: Toast
    let poolCount: Int
    let isRerollLocked: Bool
    let onReroll: () -> Void
    let onToggleFavorite: () -> Void
    let onOpenDetail: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var rerollCount = 0

    private var isFavorite: Bool { toast.favorite != nil }
    private var canReroll: Bool { poolCount > 1 }

    var body: some View {
        VStack(spacing: 12) {
            rerollButton

            if dynamicTypeSize >= .accessibility1 {
                VStack(spacing: 12) {
                    detailButton
                    HStack(spacing: 12) {
                        favoriteButton
                        shareButton
                    }
                }
            } else {
                HStack(spacing: 12) {
                    detailButton
                    favoriteButton
                    shareButton
                }
            }

            if !canReroll {
                Text("이 카테고리엔 건배사가 하나뿐이에요")
                    .font(.caption)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .sensoryFeedback(trigger: isFavorite) { _, now in
            now ? .success : .selection
        }
    }

    // MARK: Detail

    private var detailButton: some View {
        Button(action: onOpenDetail) {
            Label("낭독 모드", systemImage: "text.viewfinder")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint("크게 보기 화면으로 이동합니다")
    }

    // MARK: Favorite

    private var favoriteButton: some View {
        Button(action: onToggleFavorite) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.accentGold : Color.white)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color.surfaceElevated))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가")
        .accessibilityValue(isFavorite ? "추가됨" : "추가 안 됨")
        .accessibilityAddTraits(isFavorite ? [.isSelected] : [])
    }

    // MARK: Re-roll

    private var rerollButton: some View {
        Button {
            rerollCount += 1
            onReroll()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "dice.fill")
                    .symbolEffect(.bounce, value: rerollCount)
                Text("다시 뽑기")
            }
        }
        .buttonStyle(RandomPrimaryButtonStyle())
        .sensoryFeedback(.impact, trigger: rerollCount)
        .disabled(!canReroll || isRerollLocked)
        .opacity(canReroll ? 1 : 0.4)
        .accessibilityLabel("다시 뽑기")
        .accessibilityHint("다른 건배사를 무작위로 다시 고릅니다")
        .accessibilityValue(canReroll ? "" : "사용할 수 없음")
    }

    // MARK: Share

    private var shareButton: some View {
        ToastShareButton(toast: toast) {
            Image(systemName: "square.and.arrow.up")
                .font(.title3)
                .foregroundStyle(Color.white)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Color.surfaceElevated))
                .contentShape(Circle())
        }
        .accessibilityLabel("카드로 공유")
    }
}
