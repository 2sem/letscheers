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
    
    private var gridColumns: [GridItem] {
        let columnCount = (horizontalSizeClass == .regular) ? 4 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: columnCount)
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 24) {
                ForEach(viewModel.categories) { category in
                    // Replace .ads category with NativeAdCell
                    if category.type == .ads {
                        NativeAdCell()
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
        .background {
            ZStack(alignment: .bottom) {
                Color(red: 0.847, green: 0.834, blue: 0.886)
                Image("bg_cheers")
                    .resizable()
                    .scaledToFit()
            }.ignoresSafeArea()
        }
        .navigationTitle("술마셔 건배사")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.367, green: 0.138, blue: 0.812), for: .navigationBar)
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
            // Get background image name from category name mapping
            let bgImageName = getBackgroundImageName(for: name)
            router.navigate(to: .toastList(
                category: name,
                title: category.title,
                backgroundImage: bgImageName
            ))
        case .favorite:
            router.navigate(to: .favorites)
        case .ads:
            // Ads cell - do nothing on tap
            break
        }
    }
    
    private func getBackgroundImageName(for categoryName: String) -> String? {
        switch categoryName {
        case "선창!후창~!":
            return "bg_follow.jpg"
        case "모임":
            return "bg_meeting.jpg"
        case "회식":
            return "bg_dining.jpg"
        case "건강":
            return "bg_health.jpg"
        default:
            return nil
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

        // Show interstitial ad first
        Task {
            await adManager.show(unit: .full)
            // Show alert with random toast
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
                
                // Icon container - scales based on cell width
                let iconContainerSize = min(geometry.size.width * 0.65, geometry.size.height * 0.5)
                
                if category.type == .ads {
                    // Ads cell - TODO: will be replaced with actual ad view
                    ZStack {
                        Color(red: 0.938, green: 0.924, blue: 0.980)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(systemName: "megaphone.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color(red: 0.479, green: 0.262, blue: 0.871))
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)
                    
                    Text("광고")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                    
                    Text("")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                        .frame(height: 30)
                    
                } else if category.type == .favorite {
                    // Favorite cell
                    ZStack {
                        Color(red: 0.938, green: 0.924, blue: 0.980)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(systemName: "star.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color(red: 0.479, green: 0.262, blue: 0.871))
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)
                    
                    Text(category.title)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                    
                    Text("\(category.count)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                        .frame(height: 30)
                    
                } else {
                    // Normal category cell
                    ZStack {
                        Color(red: 0.938, green: 0.924, blue: 0.980)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Image(uiImage: category.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .padding(iconContainerSize * 0.15)
                            .foregroundColor(Color(red: 0.479, green: 0.262, blue: 0.871))
                    }
                    .frame(width: iconContainerSize, height: iconContainerSize)
                    
                    Text(category.name ?? "")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(red: 0.581, green: 0.576, blue: 0.596))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(height: 24)
                    
                    Text("\(category.count)")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(Color(red: 0.369, green: 0.368, blue: 0.384))
                        .frame(height: 30)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
        }
    }
}
