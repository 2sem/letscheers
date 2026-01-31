//
//  FavoritesScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import CoreData

struct FavoritesScreen: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: FavoriteToast.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FavoriteToast.name, ascending: true)],
        animation: .default
    )
    private var favorites: FetchedResults<FavoriteToast>
    
    @Environment(\.editMode) private var editMode
    @State private var selectedToast: (name: String, contents: String)?
    @State private var showShareAlert = false
    
    private let modelController = LCModelController.shared
    
    var body: some View {
        ZStack {
            // Background color (same as other screens)
            Color(red: 0.847, green: 0.834, blue: 0.886)
                .ignoresSafeArea()
            
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
                    ForEach(favorites, id: \.objectID) { favorite in
                        Button {
                            if editMode?.wrappedValue.isEditing == false {
                                showToastAlert(favorite)
                            }
                        } label: {
                            FavoriteRow(favorite: favorite)
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.white.opacity(0.5))
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
        .alert(selectedToast?.name ?? "", isPresented: $showShareAlert) {
            Button("공유") {
                if let toast = selectedToast {
                    shareToast(name: toast.name, contents: toast.contents)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            if let toast = selectedToast {
                Text(toast.contents)
            }
        }
    }
    
    private func showToastAlert(_ favorite: FavoriteToast) {
        let name = favorite.name ?? ""
        // Look up full contents from Excel controller
        let contents = LCExcelController.shared.findToast(name)?.contents ?? ""
        
        selectedToast = (name: name, contents: contents)
        showShareAlert = true
    }
    
    private func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            modelController.removeFavorite(toast: favorite)
        }
        modelController.saveChanges()
    }
    
    private func shareToast(name: String, contents: String) {
        var contentsText = contents
        if !contentsText.isEmpty {
            contentsText = "\n- " + contentsText
        }
        
        let tag = UIApplication.shared.displayName != nil ? "" : "\n#" + (UIApplication.shared.displayName ?? "")
        let message = name + contentsText + tag
        
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
    let favorite: FavoriteToast
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(favorite.name ?? "")
                    .font(.headline)
                    .foregroundColor(.black)
                
                if let contents = LCExcelController.shared.findToast(favorite.name ?? "")?.contents {
                    Text(contents)
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}
