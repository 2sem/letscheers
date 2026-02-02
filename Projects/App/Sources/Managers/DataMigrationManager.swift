//
//  DataMigrationManager.swift
//  letscheers
//
//  Created by Claude Code on 2026. 1. 31.
//  Copyright © 2026 leesam. All rights reserved.
//

import Foundation
import CoreData
import SwiftData

/// Handles migration from Core Data to Swift Data
/// Observable object for real-time progress updates in SplashScreen
@MainActor
class DataMigrationManager: ObservableObject {
    @Published var migrationProgress: Double = 0.0
    @Published var migrationStatus: MigrationStatus = .idle
    @Published var currentStep: String = ""
    
    enum MigrationStatus {
        case idle
        case checking
        case migrating
        case completed
        case skipped
        case failed(Error)
    }
    
    private lazy var coreDataContext: NSManagedObjectContext? = {
        guard let modelURL = Bundle.main.url(forResource: "letscheers", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("[DataMigration] Could not load Core Data model")
            return nil
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = psc
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let docUrl = urls.last else {
            print("[DataMigration] Could not get document directory")
            return nil
        }
        
        let storeURL = docUrl.appendingPathComponent("letscheers").appendingPathExtension("sqlite")
        
        do {
            try psc.addPersistentStore(
                ofType: NSSQLiteStoreType,
                configurationName: nil,
                at: storeURL,
                options: [
                    NSMigratePersistentStoresAutomaticallyOption: true,
                    NSInferMappingModelAutomaticallyOption: true
                ]
            )
            return context
        } catch {
            print("[DataMigration] Could not add persistent store: \(error)")
            return nil
        }
    }()
    
    var isMigrationCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: "dataMigrationCompleted") }
        set { UserDefaults.standard.set(newValue, forKey: "dataMigrationCompleted") }
    }
    
    func migrateToSwiftData(modelContext: ModelContext) async -> MigrationStatus {
        print("[DataMigration] migrateToSwiftData started")

        if isMigrationCompleted {
            print("[DataMigration] Migration already completed, skipping")
            migrationStatus = .skipped
            currentStep = "Migration already completed"
            return .skipped
        }

        migrationStatus = .checking
        currentStep = "Initializing..."
        print("[DataMigration] Starting initialization and migration")

        do {
            try await performMigration(modelContext: modelContext)
            print("[DataMigration] Migration completed successfully")
            migrationStatus = .completed
            currentStep = "Migration completed"
            isMigrationCompleted = true
            return .completed
        } catch {
            print("[DataMigration] Migration failed: \(error.localizedDescription)")
            migrationStatus = .failed(error)
            currentStep = "Migration failed: \(error.localizedDescription)"
            return .failed(error)
        }
    }
    
    /// Check if Core Data has any data to migrate
    private func hasCoreData() async -> Bool {
        print("[DataMigration] Checking Core Data entities")
        
        guard let context = coreDataContext else {
            print("[DataMigration] No Core Data context available")
            return false
        }
        
        return await withCheckedContinuation { continuation in
            context.perform {
                let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "FavoriteToast")
                request.fetchLimit = 1
                
                do {
                    let count = try context.count(for: request)
                    let hasData = count > 0
                    print("[DataMigration] Core Data check - favorites: \(count), hasData: \(hasData)")
                    continuation.resume(returning: hasData)
                } catch {
                    print("[DataMigration] Error checking Core Data: \(error)")
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    /// Perform the actual migration
    private func performMigration(modelContext: ModelContext) async throws {
        print("[DataMigration] performMigration started")

        // Step 1: Initialize Swift Data with Excel data if it's the first launch
        if !isSwiftDataInitialized(modelContext: modelContext) {
            currentStep = "Loading toasts from Excel..."
            migrationProgress = 0.1
            print("[DataMigration] Initializing Swift Data from Excel")
            try await initSwiftDataFromExcel(with: modelContext)
            print("[DataMigration] Excel data initialization completed")
        } else {
            print("[DataMigration] Swift Data is already initialized, skipping Excel import")
        }

        // Step 2: Migrate Core Data favorites (if any exist)
        if await hasCoreData() {
            currentStep = "Migrating favorites..."
            migrationProgress = 0.6
            print("[DataMigration] Starting favorites migration")
            
            try await migrateFavorites(with: modelContext)
            print("[DataMigration] Favorites migration completed")

            currentStep = "Cleaning up..."
            migrationProgress = 0.9
            print("[DataMigration] Starting cleanup")

            await cleanupCoreDataFiles()
            print("[DataMigration] Cleanup completed")
        } else {
            print("[DataMigration] No Core Data favorites found, skipping migration")
        }

        migrationProgress = 1.0
    }

    /// Check if Swift Data has been initialized with toasts
    private func isSwiftDataInitialized(modelContext: ModelContext) -> Bool {
        do {
            let descriptor = FetchDescriptor<Toast>()
            let toasts = try modelContext.fetch(descriptor)
            return !toasts.isEmpty
        } catch {
            print("[DataMigration] Error checking if SwiftData is initialized: \(error)")
            return false
        }
    }
    
    private func loadCoreDataFavorites() async throws -> [FavoriteToast]? {
        guard let context = coreDataContext else {
            print("[DataMigration] No Core Data context available, skipping migration")
            return nil
        }

        return try await withCheckedThrowingContinuation { continuation in
            context.perform {
                let fetchRequest: NSFetchRequest<FavoriteToast> = NSFetchRequest(entityName: "FavoriteToast")

                do {
                    let favorites = try context.fetch(fetchRequest)
                    print("[DataMigration] Fetched \(favorites.count) favorites from Core Data")
                    continuation.resume(returning: favorites)
                } catch {
                    print("[DataMigration] Error fetching favorites: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// Migrate Favorites from Core Data to Swift Data with relationships
    private func migrateFavorites(with modelContext: ModelContext) async throws {
        print("[DataMigration] Fetching Core Data favorites")

        guard let coreDataFavorites = try? await loadCoreDataFavorites() else {
            print("[DataMigration] No Core Data favorites found, skipping migration")
            return
        }

        let totalItems = coreDataFavorites.count
        print("[DataMigration] Starting migration of \(totalItems) favorites")

        for (i, coreDataFavorite) in coreDataFavorites.enumerated() {
            // Extract data from Core Data object
            let name = coreDataFavorite.name ?? ""
            let categoryName = coreDataFavorite.category
            
            // Find matching Toast in Swift Data by name and category
            let toastDescriptor = FetchDescriptor<Toast>(
                predicate: #Predicate { toast in
                    toast.title == name && (toast.category?.name == categoryName)
                }
            )

            if let matchingToast = try? modelContext.fetch(toastDescriptor).first {
                // Create Favorite with relationship to Toast
                let swiftDataFavorite = Favorite(toast: matchingToast)
                modelContext.insert(swiftDataFavorite)
                print("[DataMigration] Migrated favorite: \(name)")
            } else {
                print("[DataMigration] Warning: Could not find matching toast for favorite: \(name)")
            }

            // Batch save every 50 items for performance
            if (i + 1) % 50 == 0 {
                try modelContext.save()
                print("[DataMigration] Saved batch at \(i + 1) items")
            }

            // Update progress
            if (i + 1) % 5 == 0 || i == totalItems - 1 {
                let progress = 0.6 + (Double(i + 1) / Double(totalItems)) * 0.3
                await MainActor.run {
                    self.migrationProgress = min(progress, 0.9)
                }
            }
        }

        // Final save
        try modelContext.save()
        print("[DataMigration] Saved \(totalItems) favorites to SwiftData")
    }
    
    /// Migrate Toasts and Categories from Excel to Swift Data
    /// Initialize Swift Data with Excel data (first launch only)
    private func initSwiftDataFromExcel(with modelContext: ModelContext) async throws {
        print("[DataMigration] Loading toasts from Excel")

        // Load categories from Excel
        LCExcelController.shared.loadFromFlie()
        let excelCategories = LCExcelController.shared.categories

        var categoryOrder = 0
        for excelCategory in excelCategories {
            // Create ToastCategory in Swift Data
            let category = ToastCategory(
                name: excelCategory.name ?? excelCategory.title,
                title: excelCategory.title,
                sortOrder: categoryOrder
            )
            modelContext.insert(category)
            categoryOrder += 1

            // Create all toasts in this category with relationship
            for excelToast in excelCategory.toasts {
                let toast = Toast(
                    no: excelToast.no ?? 0,
                    title: excelToast.title ?? "",
                    contents: excelToast.contents ?? "",
                    category: category  // Set relationship
                )
                modelContext.insert(toast)
                category.toasts.append(toast)
            }
        }

        // Save all data
        try modelContext.save()
        print("[DataMigration] Saved \(excelCategories.count) categories and their toasts to SwiftData")
    }

    /// Clean up old Core Data files after successful migration
    private func cleanupCoreDataFiles() async {
        print("[DataMigration] Starting Core Data entities cleanup")
        
        guard let context = coreDataContext else {
            print("[DataMigration] Warning: No Core Data context available for cleanup")
            return
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavoriteToast")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("[DataMigration] Core Data entities cleaned up")
        } catch {
            print("[DataMigration] Error cleaning up Core Data entities: \(error)")
        }
        print("[DataMigration] Starting Core Data files cleanup")
    }
    
    func rollback() {
        isMigrationCompleted = false
        migrationStatus = .idle
        migrationProgress = 0.0
        currentStep = ""
    }
}
