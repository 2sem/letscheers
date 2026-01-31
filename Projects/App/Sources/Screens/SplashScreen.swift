//
//  SplashScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI

struct SplashScreen: View {
    @ObservedObject var appState: AppState
    @State private var progress: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("launch_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("술마셔 건배사")
                    .font(.title)
                    .foregroundColor(.white)
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)
                    .frame(width: 200)
                    .tint(.purple)
            }
        }
        .task {
            await performInitialization()
        }
    }
    
    // MARK: - Initialization
    
    private func performInitialization() async {
        await updateProgress(0.1)
        await initializeCoreData()
        
        await updateProgress(0.5)
        loadExcelData()
        
        await updateProgress(0.9)
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        await MainActor.run {
            appState.isInitialized = true
        }
    }
    
    private func initializeCoreData() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                _ = LCModelController.shared
                continuation.resume()
            }
        }
    }
    
    private func loadExcelData() {
        _ = appState.excelController.categories
    }
    
    private func updateProgress(_ value: Double) async {
        await MainActor.run {
            withAnimation {
                self.progress = value
            }
        }
    }
}
