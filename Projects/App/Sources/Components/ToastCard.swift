//
//  ToastCard.swift
//  letscheers
//

import SwiftUI
import SwiftData

// MARK: - Card

/// Shared toast row: title + 2-line meaning + trailing favorite star.
/// Tapping the card itself is handled by the caller (`.onTapGesture`).
struct ToastCard: View {
    let toast: Toast
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(alignment: toast.contents.isEmpty ? .center : .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(toast.title)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if !toast.contents.isEmpty {
                    Text(toast.contents)
                        .font(.subheadline)
                        .foregroundStyle(Color.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)

            FavoriteStarButton(isFavorite: toast.isFavorite, action: onToggleFavorite)
        }
        .padding(16)
        .cardSurface()
        .contentShape(Rectangle())
    }
}

// MARK: - Star Button

struct FavoriteStarButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.accentGold : Color.textTertiary)
                .symbolEffect(.bounce, value: isFavorite)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sensoryFeedback(trigger: isFavorite) { _, now in now ? .success : .selection }
        .accessibilityLabel(isFavorite ? "즐겨찾기 해제" : "즐겨찾기 추가")
        .accessibilityValue(isFavorite ? "켜짐" : "꺼짐")
    }
}

// MARK: - List Row Styling

extension View {
    /// Clear, separator-less list row with the standard card insets.
    func toastCardRowStyle() -> some View {
        listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
    }
}

// MARK: - Interactive Row

/// `ToastCard` with the full set of row interactions: tap to open, swipe to
/// favorite / share, context menu, and VoiceOver actions. Used by the category
/// list and the global search results.
struct ToastCardRow: View {
    let toast: Toast
    let onOpen: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var copyTick = 0

    var body: some View {
        ToastCard(toast: toast) {
            toast.toggleFavorite(in: modelContext)
        }
        .onTapGesture(perform: onOpen)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                toast.toggleFavorite(in: modelContext)
            } label: {
                Label(toast.isFavorite ? "즐겨찾기 해제" : "즐겨찾기", systemImage: "star.fill")
            }
            .tint(Color.accentGold)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: false) {
            Button {
                ToastSharePresenter.present(toast)
            } label: {
                Label("공유", systemImage: "square.and.arrow.up")
            }
            .tint(Color.accentPurple)
        }
        .contextMenu {
            Button {
                UIPasteboard.general.string = toast.plainText
                copyTick += 1
            } label: {
                Label("복사", systemImage: "doc.on.doc")
            }
            Button {
                ToastSharePresenter.present(toast)
            } label: {
                Label("공유", systemImage: "square.and.arrow.up")
            }
            Button {
                toast.toggleFavorite(in: modelContext)
            } label: {
                Label(toast.isFavorite ? "즐겨찾기 해제" : "즐겨찾기", systemImage: toast.isFavorite ? "star.slash" : "star")
            }
        }
        .sensoryFeedback(.success, trigger: copyTick)
        .accessibilityAction(named: "즐겨찾기 토글") {
            toast.toggleFavorite(in: modelContext)
        }
        .accessibilityAction(named: "공유") {
            ToastSharePresenter.present(toast)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityAddTraits(.isHeader)
    }
}
