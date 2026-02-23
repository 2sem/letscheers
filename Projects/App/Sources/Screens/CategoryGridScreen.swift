//
//  CategoryGridScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct CategoryGridScreen: View {
    @StateObject private var viewModel = CategoryGridViewModel()
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var adManager: SwiftUIAdManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @AppStorage("LaunchCount") private var launchCount = 0

    private var gridColumns: [GridItem] {
        let columnCount = (horizontalSizeClass == .regular) ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 24) {
                ForEach(viewModel.categories) { category in
                    if category.type == .ads {
                        NativeAdCell(shouldLoadAd: launchCount > 1)
                            .aspectRatio(0.8, contentMode: .fit)
                    } else {
                        CategoryCell(category: category)
                            .aspectRatio(0.8, contentMode: .fit)
                            .onTapGesture {
                                handleCategoryTap(category)
                            }
                    }
                }
            }
            .padding(16)
        }
        .scrollDisabled(true)
        .background {
            ZStack(alignment: .bottom) {
                Color.appBackground
                Image("bg_cheers")
                    .resizable()
                    .scaledToFit()
            }.ignoresSafeArea()
        }
        .navigationTitle("술마셔 건배사")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.navBar, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    shareApp()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showRandomToast()
                } label: {
                    Image(systemName: "shuffle")
                }
            }
        }
        .task {
            viewModel.loadCategories(modelContext: modelContext)
        }
    }

    private func handleCategoryTap(_ category: CategoryViewModel) {
        switch category.type {
        case .normal:
            guard let name = category.name else { return }
            let bgImageName = getBackgroundImageName(for: name)
            router.navigate(to: .toastList(
                category: name,
                title: category.title,
                backgroundImage: bgImageName
            ))
        case .favorite:
            router.navigate(to: .favorites)
        case .ads:
            break
        }
    }

    private func getBackgroundImageName(for categoryName: String) -> String? {
        switch categoryName {
        case "선창!후창~!": return "bg_follow.jpg"
        case "모임":       return "bg_meeting.jpg"
        case "회식":       return "bg_dining.jpg"
        case "건강":       return "bg_health.jpg"
        default:          return nil
        }
    }

    private func shareApp() {
        guard let url = URL(string: "https://apps.apple.com/app/id1193053041") else { return }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }

    private func showRandomToast() {
        let toast = LCExcelController.shared.randomToast()
        Task {
            if launchCount > 1 { await adManager.show(unit: .full) }
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                let alert = UIAlertController(
                    title: toast.title ?? "추천 건배사",
                    message: toast.contents,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                rootVC.present(alert, animated: true)
            }
        }
    }
}

// MARK: - Category Cell

struct CategoryCell: View {
    let category: CategoryViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Spacer()

                let iconContainerSize = min(geometry.size.width * 0.65, geometry.size.height * 0.5)

                if category.type == .ads {
                    ZStack {
                        Color.iconContainer
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(systemName: "megaphone.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color.accentPurple)
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)

                    Text("광고")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(height: 30)

                } else if category.type == .favorite {
                    ZStack {
                        Color.iconContainer
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color.accentPurple)
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)

                    Text(category.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)

                    Text("\(category.count)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(height: 30)

                } else {
                    ZStack {
                        Color.iconContainer
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(uiImage: category.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color.accentPurple)
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)

                    Text(category.name ?? "")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(height: 24)

                    Text("\(category.count)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(height: 30)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5))
            .shadow(color: Color.accentPurple.opacity(0.12), radius: 14, x: 0, y: 6)
        }
    }
}
