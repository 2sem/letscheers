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
    @EnvironmentObject var favoritesManager: FavoritesManager
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Favorite.createdAt, order: .forward)
    private var favorites: [Favorite]

    @Environment(\.editMode) private var editMode
    @State private var selectedToast: Toast?
    @State private var showShareAlert = false

    var body: some View {
        ZStack {
            // Background color (same as other screens)
            Color.appBackground
                .ignoresSafeArea()

            VStack {
                Spacer()
                Image("bg_cheers")
                    .resizable()
                    .scaledToFit()
            }
            .ignoresSafeArea(edges: .bottom)

            if favorites.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("즐겨찾기가 없습니다")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    Text("마음에 드는 건배사를 즐겨찾기에 추가해보세요")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            } else {
                List {
                    ForEach(favorites, id: \.id) { favorite in
                        Button {
                            if editMode?.wrappedValue.isEditing == false {
                                showToastAlert(favorite)
                            }
                        } label: {
                            FavoriteRow(favorite: favorite)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.cardBackground.opacity(0.5))
                    }
                    .onDelete(perform: deleteFavorites)
                }
                .scrollContentBackground(.hidden)
            }
        }
        .navigationTitle("즐겨찾기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !favorites.isEmpty {
                    EditButton()
                }
            }
        }
        .alert(selectedToast?.title ?? "", isPresented: $showShareAlert) {
            Button("공유") {
                if let toast = selectedToast {
                    share(toast: toast)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            if let toast = selectedToast {
                Text(toast.contents)
            }
        }
    }
    
    private func showToastAlert(_ favorite: Favorite) {
        selectedToast = favorite.toast
        showShareAlert = true
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            modelContext.delete(favorite)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after deleting favorites: \(error)")
        }
    }
    
    private func share(toast: Toast) {
        var contentsText = toast.contents
        if !contentsText.isEmpty {
            contentsText = "\n- " + contentsText
        }
        
        let tag = UIApplication.shared.displayName != nil ? "" : "\n#" + (UIApplication.shared.displayName ?? "")
        let message = toast.title + contentsText + tag
        
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Favorite Row

struct FavoriteRow: View {
    let favorite: Favorite
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(favorite.toast.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(favorite.toast.contents)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
