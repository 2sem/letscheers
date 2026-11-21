//
//  HomeScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

struct HomeScreen: View {
    @StateObject private var viewModel = CategoryGridViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var coordinator: RandomToastCoordinator
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("LaunchCount") private var launchCount = 0

    @Query(sort: \Toast.no) private var allToasts: [Toast]
    @Query private var favorites: [Favorite]

    @State private var searchText = ""

    private var isRegular: Bool { horizontalSizeClass == .regular }
    private var trimmedSearch: String { searchText.trimmingCharacters(in: .whitespaces) }
    private var isSearching: Bool { !trimmedSearch.isEmpty }
    private var categories: [CategoryViewModel] { viewModel.categories.filter { $0.type == .normal } }
    private var todayToast: Toast? { Toast.toastOfTheDay(from: allToasts) }

    var body: some View {
        Group {
            if isSearching {
                HomeSearchResults(
                    query: trimmedSearch,
                    toasts: allToasts,
                    onOpen: { results, index in router.openDetail(of: results, at: index) }
                )
            } else {
                content
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { LinearGradient.appScreen.ignoresSafeArea() }
        .navigationTitle("술마셔 건배사")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "건배사 검색 (예: 당나귀, 건강)"
        )
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: shareApp) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("앱 공유")
            }
        }
        .task {
            viewModel.loadCategories(modelContext: modelContext)
        }
    }

    // MARK: - Content

    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroAndToday
                categorySection
                HomeNativeAdCard(shouldLoadAd: launchCount > 1)
                favoritesRow
            }
            .padding(.horizontal, isRegular ? 24 : 16)
            .padding(.vertical, 16)
            .readableColumn()
        }
    }

    @ViewBuilder
    private var heroAndToday: some View {
        if isRegular {
            HStack(alignment: .top, spacing: 16) {
                hero.frame(maxWidth: .infinity)
                todaySection.frame(maxWidth: .infinity)
            }
        } else {
            VStack(spacing: 24) {
                hero
                todaySection
            }
        }
    }

    private var hero: some View {
        RandomToastButton(style: .hero, pool: .all)
            .disabled(allToasts.isEmpty)
    }

    @ViewBuilder
    private var todaySection: some View {
        if let todayToast {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader("오늘의 건배사")
                TodayToastCard(toast: todayToast) {
                    router.openDetail(of: [todayToast], at: 0)
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("상황별 건배사")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                if categories.isEmpty {
                    ForEach(0..<4, id: \.self) { _ in
                        CategoryCard(name: "회식", icon: UIImage(), count: 0)
                            .redacted(reason: .placeholder)
                            .accessibilityHidden(true)
                    }
                } else {
                    ForEach(categories) { category in
                        CategoryCard(
                            name: category.name ?? "",
                            icon: category.icon,
                            count: category.count
                        )
                        .onTapGesture { open(category) }
                    }
                }
            }
        }
    }

    private var favoritesRow: some View {
        FavoritesRow(count: favorites.count)
            .onTapGesture { router.navigate(to: .favorites) }
    }

    // MARK: - Actions

    private func open(_ category: CategoryViewModel) {
        guard let name = category.name else { return }
        router.navigate(to: .toastList(category: name, title: category.title))
    }

    private func shareApp() {
        let activityVC = UIActivityViewController(activityItems: [AppLinks.appStore], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Today Card

private struct TodayToastCard: View {
    let toast: Toast
    let onTap: () -> Void

    var body: some View {
        let tint = Color.categoryTint(for: toast.category?.name)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("오늘의 건배사", systemImage: "sun.max.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentGold)

                Spacer()

                if let name = toast.category?.name {
                    Text(name)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(tint)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(tint.opacity(0.2)))
                }
            }

            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(toast.title)
                        .font(.system(.title2, design: .rounded, weight: .bold))
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

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardSurface()
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("오늘의 건배사, \(toast.title)")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Category Card

private struct CategoryCard: View {
    let name: String
    let icon: UIImage
    let count: Int

    var body: some View {
        let tint = Color.categoryTint(for: name)

        VStack(alignment: .leading, spacing: 10) {
            Image(uiImage: icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .padding(8)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text("\(count)개")
                    .font(.caption)
                    .foregroundStyle(Color.textTertiary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .cardSurface()
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), 건배사 \(count)개")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Favorites Row

private struct FavoritesRow: View {
    let count: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.title3)
                .foregroundStyle(Color.accentGold)
                .frame(width: 40, height: 40)
                .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text("즐겨찾기")
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Text(count == 0 ? "아직 없어요" : "\(count)개")
                .font(.subheadline)
                .foregroundStyle(Color.textTertiary)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textTertiary)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 64)
        .cardSurface()
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("즐겨찾기, \(count == 0 ? "아직 없어요" : "\(count)개")")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Search Results

private struct HomeSearchResults: View {
    let query: String
    let toasts: [Toast]
    let onOpen: ([Toast], Int) -> Void

    private struct ResultGroup: Identifiable {
        let name: String
        let toasts: [Toast]
        var id: String { name }
    }

    /// Title matches first, then meaning matches; grouped by category.
    private var results: [Toast] {
        let titleMatches = toasts.filter { $0.title.localizedCaseInsensitiveContains(query) }
        let titleNos = Set(titleMatches.map(\.no))
        let bodyMatches = toasts.filter {
            !titleNos.contains($0.no) && $0.contents.localizedCaseInsensitiveContains(query)
        }
        return titleMatches + bodyMatches
    }

    private var groups: [ResultGroup] {
        let byCategory = Dictionary(grouping: results) { $0.category?.name ?? "기타" }
        var order: [String] = []
        for toast in results {
            let name = toast.category?.name ?? "기타"
            if !order.contains(name) { order.append(name) }
        }
        return order.map { ResultGroup(name: $0, toasts: byCategory[$0] ?? []) }
    }

    /// Flat deck in on-screen order so swiping in detail follows the list.
    private var deck: [Toast] { groups.flatMap(\.toasts) }

    var body: some View {
        let deck = deck
        if deck.isEmpty {
            emptyState
        } else {
            List {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.toasts, id: \.no) { toast in
                            ToastCardRow(toast: toast) {
                                if let index = deck.firstIndex(where: { $0.no == toast.no }) {
                                    onOpen(deck, index)
                                }
                            }
                            .toastCardRowStyle()
                        }
                    } header: {
                        SectionHeader(group.name)
                            .padding(.horizontal, 16)
                            .textCase(nil)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .readableColumn()
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("검색 결과가 없어요", systemImage: "magnifyingglass")
        } description: {
            Text("다른 단어로 검색하거나 랜덤 건배사를 뽑아 보세요")
        } actions: {
            RandomToastButton(style: .goldPill, pool: .all)
        }
    }
}

// MARK: - Native Ad Card

/// Full-width native ad below the category grid. Collapses completely (no gap)
/// until an ad has loaded, and stays collapsed if loading fails.
private struct HomeNativeAdCard: View {
    @EnvironmentObject private var adManager: SwiftUIAdManager
    let shouldLoadAd: Bool

    var body: some View {
        NativeAdSwiftUIView(adUnit: .native, shouldLoadAd: shouldLoadAd) { phase in
            if let ad = phase.ad {
                card(for: ad)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("광고. \(ad.headline ?? ""). \(ad.callToAction ?? ad.advertiser ?? "")")
                    .accessibilityAddTraits(.isButton)
            }
        }
        .task {
            await adManager.requestAppTrackingIfNeed()
        }
    }

    private func card(for ad: NativeAd) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("광고")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(Color.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.surfaceElevated))
                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                if let icon = ad.icon?.image {
                    Image(uiImage: icon)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(ad.headline ?? "추천 콘텐츠")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                    if let body = ad.body, !body.isEmpty {
                        Text(body)
                            .font(.subheadline)
                            .foregroundStyle(Color.textSecondary)
                            .lineLimit(3)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if ad.mediaContent.hasVideoContent || ad.mediaContent.aspectRatio > 0 {
                MediaViewSwiftUIView(mediaContent: ad.mediaContent)
                    .aspectRatio(max(ad.mediaContent.aspectRatio, 1.2), contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .cardSurface()
    }
}
