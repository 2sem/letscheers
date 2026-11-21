//
//  ToastListScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

struct ToastListScreen: View {
    let title: String
    let viewModel: ToastListViewModel

    var body: some View {
        ToastListContent(title: title, viewModel: viewModel)
    }
}

// MARK: - Content View

private struct ToastListContent: View {
    let title: String
    @ObservedObject var viewModel: ToastListViewModel
    @Query var toasts: [Toast]
    @Query private var categoryMatches: [ToastCategory]

    @EnvironmentObject private var router: NavigationRouter
    @AppStorage("LaunchCount") private var launchCount = 0

    init(title: String, viewModel: ToastListViewModel) {
        self.title = title
        self.viewModel = viewModel

        let categoryName = viewModel.categoryName
        _toasts = Query(filter: #Predicate<Toast>{ toast in
            toast.category?.name == categoryName
        }, sort: \.no, order: .reverse)
        _categoryMatches = Query(filter: #Predicate<ToastCategory> { category in
            category.name == categoryName
        })
    }

    private var randomPool: RandomPool? {
        categoryMatches.first.map { .category($0.persistentModelID) }
    }

    /// Placement rules (manager decision on issue #91):
    /// - no ads while searching
    /// - lists shorter than 5 toasts get no ad
    /// - first ad after toast index 4, then one every 10 toasts (index 4, 14, 24, …)
    private static let firstAdAfterIndex = 4
    private static let adInterval = 10

    private var displayItems: [ToastListItem] {
        let toasts = viewModel.filteredToasts

        guard viewModel.searchText.isEmpty,
              toasts.count > Self.firstAdAfterIndex else {
            return toasts.map { .toast($0) }
        }

        var items: [ToastListItem] = []
        var slotIndex = 0
        for (index, toast) in toasts.enumerated() {
            items.append(.toast(toast))
            if index >= Self.firstAdAfterIndex,
               (index - Self.firstAdAfterIndex) % Self.adInterval == 0 {
                items.append(.ad(slotIndex: slotIndex))
                slotIndex += 1
            }
        }
        return items
    }

    var body: some View {
        list
            .overlay { emptyState }
            .background { LinearGradient.appScreen.ignoresSafeArea() }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "검색")
            .onChange(of: viewModel.searchText, {
                self.viewModel.refresh(toasts: toasts)
            })
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    RandomToastButton(style: .icon, pool: randomPool)
                }
            }
            .task {
                self.viewModel.refresh(toasts: toasts)
            }
    }

    // MARK: - Sections

    private var list: some View {
        List {
            Text("\(viewModel.filteredToasts.count)개")
                .font(.footnote)
                .foregroundStyle(Color.textTertiary)
                .toastCardRowStyle()

            ForEach(displayItems) { item in
                switch item {
                case .toast(let toast):
                    ToastCardRow(toast: toast.toast) {
                        open(toast)
                    }
                    .toastCardRowStyle()
                case .ad:
                    ToastListNativeAdRow(
                        shouldLoadAd: launchCount > 1,
                        backgroundRowColor: .cardBackground
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .readableColumn()
    }

    @ViewBuilder
    private var emptyState: some View {
        if !viewModel.searchText.isEmpty && viewModel.filteredToasts.isEmpty {
            ContentUnavailableView(
                "검색 결과가 없어요",
                systemImage: "magnifyingglass",
                description: Text("다른 단어로 검색해 보세요")
            )
        } else if toasts.isEmpty {
            ContentUnavailableView("건배사가 없어요", systemImage: "wineglass")
        }
    }

    // MARK: - Actions

    private func open(_ toast: ToastViewModel) {
        let deck = viewModel.filteredToasts.map(\.toast)
        guard let index = deck.firstIndex(where: { $0.no == toast.toast.no }) else { return }
        router.openDetail(of: deck, at: index)
    }
}

// MARK: - Display Model

/// A toast list row is either a toast or an interleaved native-ad slot.
private enum ToastListItem: Identifiable {
    case toast(ToastViewModel)
    case ad(slotIndex: Int)

    /// Stable across scrolls so ad rows never reload and toast identity is preserved.
    var id: String {
        switch self {
        case .toast(let viewModel): return "toast-\(viewModel.id)"
        case .ad(let slotIndex): return "ad-\(slotIndex)"
        }
    }
}
