//
//  SplashScreen.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

struct SplashScreen: View {
    @ObservedObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var migrationManager = DataMigrationManager()
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
                
                // Show migration progress if migrating
                if case .migrating = migrationManager.migrationStatus {
                    Text(migrationManager.currentStep)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
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
        // Run migration if Core Data exists (handles favorites migration)
        // This will skip if already migrated or no Core Data exists
        let migrationResult = await migrateToSwiftData()
        await updateProgress(0.3)

        // Check if this is first launch or needs migration
        if await isSwiftDataEmpty() {
            // Fresh install: Initialize from Excel
            await initializeFromExcel()
            await updateProgress(0.9)
        } else {
            // Check if Excel version has changed
            let excelVersion = LCExcelController.shared.readVersion()
            let lastVersion = LSDefaults.LastDataVersion

            if let excelVersion = excelVersion, excelVersion != lastVersion {
                print("[SplashScreen] Version mismatch - Excel: \(excelVersion), Last: \(lastVersion ?? "none")")
                await syncFromExcel()
            }
            await updateProgress(0.9)
        }

        // Brief pause for smooth UI transition
        try? await Task.sleep(nanoseconds: 300_000_000)
        await updateProgress(1.0)

        await MainActor.run {
            appState.isInitialized = true
        }
    }
    
    private func isSwiftDataEmpty() async -> Bool {
        let descriptor = FetchDescriptor<Toast>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        return count == 0
    }
    
    private func initializeFromExcel() async {
        await updateProgress(0.1)
        print("[SplashScreen] Initializing Swift Data from Excel")

        // Load categories from Excel
        LCExcelController.shared.loadFromFlie()
        let excelCategories = LCExcelController.shared.categories

        var categoryOrder = 0
        for excelCategory in excelCategories {
            // Create ToastCategory
            let category = ToastCategory(
                name: excelCategory.name ?? excelCategory.title,
                title: excelCategory.title,
                sortOrder: categoryOrder
            )
            modelContext.insert(category)
            categoryOrder += 1

            // Create all toasts in this category
            for excelToast in excelCategory.toasts {
                let toast = Toast(
                    no: excelToast.no ?? 0,
                    title: excelToast.title ?? "",
                    contents: excelToast.contents ?? "",
                    category: category
                )
                modelContext.insert(toast)
                category.toasts.append(toast)
            }

            // Update progress
            await updateProgress(0.1 + (Double(categoryOrder) / Double(excelCategories.count)) * 0.5)
        }

        // Save all data and store version
        try? modelContext.save()
        if let version = LCExcelController.shared.readVersion() {
            LSDefaults.LastDataVersion = version
            print("[SplashScreen] Stored data version: \(version)")
        }
        print("[SplashScreen] Initialized \(excelCategories.count) categories from Excel")
    }
    
    private func syncFromExcel() async {
        print("[SplashScreen] Syncing Swift Data with Excel")

        // Load fresh data from Excel
        LCExcelController.shared.loadFromFlie()
        let excelCategories = LCExcelController.shared.categories

        // Build a map of excel toasts by their unique 'no' identifier
        var excelToastsByNo: [Int16: (toast: LCToast, category: LCToastCategory)] = [:]
        for excelCategory in excelCategories {
            for excelToast in excelCategory.toasts {
                if let no = excelToast.no {
                    excelToastsByNo[no] = (excelToast, excelCategory)
                }
            }
        }

        // Fetch all existing toasts
        let toastDescriptor = FetchDescriptor<Toast>()
        guard let existingToasts = try? modelContext.fetch(toastDescriptor) else {
            print("[SplashScreen] Failed to fetch existing toasts")
            return
        }

        // Build a map of existing toasts by 'no'
        var existingToastsByNo: [Int16: Toast] = [:]
        for toast in existingToasts {
            existingToastsByNo[toast.no] = toast
        }

        // Fetch all existing categories
        let categoryDescriptor = FetchDescriptor<ToastCategory>()
        guard let existingCategories = try? modelContext.fetch(categoryDescriptor) else {
            print("[SplashScreen] Failed to fetch existing categories")
            return
        }

        // Build a map of existing categories by name
        var categoryMap: [String: ToastCategory] = [:]
        for category in existingCategories {
            categoryMap[category.name] = category
        }

        var updateCount = 0
        var insertCount = 0
        var deleteCount = 0

        // Process updates and inserts
        for (no, excelData) in excelToastsByNo {
            let excelToast = excelData.toast
            let excelCategory = excelData.category
            guard let categoryName = excelCategory.name ?? excelCategory.title else {
                continue
            }

            if let existingToast = existingToastsByNo[no] {
                // Update existing toast
                var needsUpdate = false

                if existingToast.title != excelToast.title {
                    existingToast.title = excelToast.title ?? ""
                    needsUpdate = true
                }

                if existingToast.contents != excelToast.contents {
                    existingToast.contents = excelToast.contents ?? ""
                    needsUpdate = true
                }

                // Check if category needs update
                if existingToast.category?.name != categoryName {
                    // Get or create category
                    var category = categoryMap[categoryName]
                    if category == nil {
                        let newCategory = ToastCategory(
                            name: categoryName,
                            title: excelCategory.title,
                            sortOrder: categoryMap.count
                        )
                        modelContext.insert(newCategory)
                        categoryMap[categoryName] = newCategory
                        category = newCategory
                    }
                    existingToast.category = category
                    needsUpdate = true
                }

                if needsUpdate {
                    updateCount += 1
                }
            } else {
                // Insert new toast
                var category = categoryMap[categoryName]
                if category == nil {
                    let newCategory = ToastCategory(
                        name: categoryName,
                        title: excelCategory.title,
                        sortOrder: categoryMap.count
                    )
                    modelContext.insert(newCategory)
                    categoryMap[categoryName] = newCategory
                    category = newCategory
                }

                let newToast = Toast(
                    no: no,
                    title: excelToast.title ?? "",
                    contents: excelToast.contents ?? "",
                    category: category
                )
                modelContext.insert(newToast)
                category?.toasts.append(newToast)
                insertCount += 1
            }
        }

        // Process deletes - remove toasts that exist in DB but not in Excel
        for (no, existingToast) in existingToastsByNo {
            if excelToastsByNo[no] == nil {
                // Toast no longer exists in Excel, delete it
                modelContext.delete(existingToast)
                deleteCount += 1
            }
        }

        // Save changes and update version
        try? modelContext.save()
        if let version = LCExcelController.shared.readVersion() {
            LSDefaults.LastDataVersion = version
            print("[SplashScreen] Updated data version: \(version)")
        }

        print("[SplashScreen] Sync complete - Updated: \(updateCount), Inserted: \(insertCount), Deleted: \(deleteCount)")
    }

    private func migrateToSwiftData() async -> DataMigrationManager.MigrationStatus {
        let migrationResult = await migrationManager.migrateToSwiftData(modelContext: modelContext)

        // Sync migration progress with splash progress (60-90% range)
        await MainActor.run {
            self.progress = 0.6 + (migrationManager.migrationProgress * 0.3)
        }

        return migrationResult
    }
    
    private func updateProgress(_ value: Double) async {
        await MainActor.run {
            withAnimation {
                self.progress = value
            }
        }
    }
}

