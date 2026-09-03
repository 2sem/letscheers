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
    let backgroundImage: UIImage?
    let viewModel: ToastListViewModel

    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        ToastListContent(
            title: title,
            backgroundImage: backgroundImage,
            viewModel: viewModel
        )
    }
}

// MARK: - Content View

private struct ToastListContent: View {
    @Environment(\.modelContext) private var modelContext

    let title: String
    let backgroundImage: UIImage?
    @ObservedObject var viewModel: ToastListViewModel
    @Query var toasts: [Toast]
    @Query private var categoryMatches: [ToastCategory]

    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var selectedToast: ToastViewModel?
    @State private var showShareAlert = false
    @AppStorage("LaunchCount") private var launchCount = 0

    init(title: String, backgroundImage: UIImage?, viewModel: ToastListViewModel) {
        self.title = title
        self.backgroundImage = backgroundImage
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

    private var backgroundRowColor: Color {
        Color.cardBackground.opacity(backgroundImage != nil ? 0.5 : 1.0)
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
        ZStack {
            // Base background color (same as category grid)
            Color.appBackground
                .ignoresSafeArea()

            // Background image layer
            if let background = backgroundImage {
                GeometryReader { geometry in
                    Image(uiImage: background)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .opacity(0.2)
                }
                .ignoresSafeArea()
            }

            // List layer
            List {
                ForEach(displayItems) { item in
                    switch item {
                    case .toast(let toast):
                        ToastRow(viewModel: toast) {
                            viewModel.toggleFavorite(for: toast, modelContext: modelContext)
                        }
                        .listRowBackground(backgroundRowColor)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedToast = toast
                            showShareAlert = true
                        }
                    case .ad:
                        ToastListNativeAdRow(
                            shouldLoadAd: launchCount > 1,
                            backgroundRowColor: backgroundRowColor
                        )
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
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
        .alert(selectedToast?.toast.title ?? "추천 건배사", isPresented: $showShareAlert) {
            Button("공유") {
                if let toast = selectedToast {
                    shareToast(toast)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            if let toast = selectedToast {
                Text(toast.toast.contents)
            }
        }
        .task {
            self.viewModel.refresh(toasts: toasts)
        }
    }

    private func shareToast(_ toastViewModel: ToastViewModel) {
        let toast = toastViewModel.toast
        var contents = toast.contents
        if !contents.isEmpty {
            contents = "\n- " + contents
        }

        let tag = UIApplication.shared.displayName != nil ? "" : "\n#" + (UIApplication.shared.displayName ?? "")
        let message = toast.title + contents + tag

        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
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

// MARK: - Toast Row

struct ToastRow: View {
    let viewModel: ToastViewModel
    let onFavoriteTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.toast.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(viewModel.toast.contents)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()

            Button {
                onFavoriteTap()
            } label: {
                Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(viewModel.isFavorite ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
