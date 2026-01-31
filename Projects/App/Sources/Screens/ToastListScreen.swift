//
//  ToastListScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct ToastListScreen: View {
    let category: String
    let title: String
    let backgroundImage: UIImage?
    
    @StateObject private var viewModel: ToastListViewModel
    @State private var selectedToast: ToastViewModel?
    @State private var showShareAlert = false
    
    init(category: String, title: String, backgroundImage: UIImage?) {
        self.category = category
        self.title = title
        self.backgroundImage = backgroundImage
        _viewModel = StateObject(wrappedValue: ToastListViewModel(category: category))
    }
    
    private var backgroundRowColor: Color {
        if backgroundImage != nil {
            return Color.white.opacity(0.5)
        } else {
            return Color.white
        }
    }
    
    var body: some View {
        ZStack {
            // Base background color (same as category grid)
            Color(red: 0.847, green: 0.834, blue: 0.886)
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
                ForEach(viewModel.filteredToasts) { toast in
                    ToastRow(toast: toast) {
                        viewModel.toggleFavorite(for: toast)
                    }
                    .listRowBackground(backgroundRowColor)
                    .onTapGesture {
                        selectedToast = toast
                        showShareAlert = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $viewModel.searchText, prompt: "검색")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showRandomToast()
                } label: {
                    Image(systemName: "shuffle")
                }
            }
        }
        .alert(selectedToast?.title ?? "추천 건배사", isPresented: $showShareAlert) {
            Button("공유") {
                if let toast = selectedToast {
                    shareToast(toast)
                }
            }
            Button("확인", role: .cancel) {}
        } message: {
            if let toast = selectedToast {
                Text(toast.contents)
            }
        }
        .onAppear {
            // Show interstitial ad when entering screen
            AppDelegate.sharedGADManager?.show(unit: .full, completion: nil)
        }
    }
    
    private func showRandomToast() {
        guard let toast = viewModel.randomToast() else { 
            print("Failed to get random toast")
            return 
        }
        
        print("Random toast: \(toast.title)")
        
        // Show interstitial ad first, then alert
        AppDelegate.sharedGADManager?.show(unit: .full) { _, _, _ in
            DispatchQueue.main.async {
                self.selectedToast = toast
                self.showShareAlert = true
            }
        } ?? {
            // If ad manager not available, show alert directly
            DispatchQueue.main.async {
                self.selectedToast = toast
                self.showShareAlert = true
            }
        }()
    }
    
    private func shareToast(_ toast: ToastViewModel) {
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

// MARK: - Toast Row

struct ToastRow: View {
    let toast: ToastViewModel
    let onFavoriteTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(toast.title)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(toast.contents)
                    .font(.subheadline)
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(3)
            }
            
            Spacer()
            
            Button {
                onFavoriteTap()
            } label: {
                Image(systemName: toast.isFavorite ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundColor(toast.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}
