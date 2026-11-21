//
//  FavoritesScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

struct FavoritesScreen: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: NavigationRouter
    @Query(sort: \Favorite.createdAt, order: .forward)
    private var favorites: [Favorite]

    @State private var editMode: EditMode = .inactive
    @State private var deleteTick = 0

    private var isEditing: Bool { editMode.isEditing }

    var body: some View {
        Group {
            if favorites.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { LinearGradient.appScreen.ignoresSafeArea() }
        .navigationTitle("즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !favorites.isEmpty {
                    Button(isEditing ? "완료" : "편집") {
                        withAnimation { editMode = isEditing ? .inactive : .active }
                    }
                    .foregroundStyle(Color.accentGold)
                }
            }
        }
        .environment(\.editMode, $editMode)
        .sensoryFeedback(.impact, trigger: deleteTick)
    }

    // MARK: - Sections

    private var list: some View {
        List {
            Text("\(favorites.count)개의 나만의 건배사")
                .font(.footnote)
                .foregroundStyle(Color.textTertiary)
                .toastCardRowStyle()

            ForEach(favorites, id: \.persistentModelID) { favorite in
                ToastCard(toast: favorite.toast) {
                    delete(favorite)
                }
                .onTapGesture {
                    open(favorite)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        delete(favorite)
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    Button {
                        ToastSharePresenter.present(favorite.toast)
                    } label: {
                        Label("공유", systemImage: "square.and.arrow.up")
                    }
                    .tint(Color.accentPurple)
                }
                .toastCardRowStyle()
            }
            .onDelete(perform: deleteFavorites)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .readableColumn()
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("아직 즐겨찾기가 없어요", systemImage: "star")
        } description: {
            Text("마음에 드는 건배사의 별을 눌러 모아 보세요")
        } actions: {
            Button {
                router.navigateToRoot()
            } label: {
                Text("건배사 둘러보기")
                    .font(.headline)
                    .foregroundStyle(Color.onGold)
                    .padding(.horizontal, 20)
                    .frame(minHeight: 44)
                    .background(Capsule().fill(Color.accentGold))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func open(_ favorite: Favorite) {
        guard !isEditing else { return }
        let deck = favorites.map(\.toast)
        guard let index = favorites.firstIndex(where: { $0.persistentModelID == favorite.persistentModelID }) else { return }
        router.openDetail(of: deck, at: index)
    }

    private func delete(_ favorite: Favorite) {
        favorite.toast.favorite = nil
        modelContext.delete(favorite)
        save()
    }

    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            favorite.toast.favorite = nil
            modelContext.delete(favorite)
        }
        save()
    }

    private func save() {
        deleteTick += 1
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after deleting favorites: \(error)")
        }
    }
}
