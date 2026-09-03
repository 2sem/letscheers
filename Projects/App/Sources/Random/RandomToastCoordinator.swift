//
//  RandomToastCoordinator.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import Combine
import SwiftUI
import SwiftData

// MARK: - Supporting Types

enum RandomError: Equatable {
    case emptyPool
    case emptyDatabase
}

enum RandomPool: Equatable {
    case all
    case category(PersistentIdentifier)
}

/// Coarse busy flag for the nav control (disable + spin the glyph).
enum RandomRollState: Equatable {
    case idle
    /// Toast picked, brief cosmetic spin before the sheet presents.
    case rolling
    /// A sheet (flow or empty) is on screen.
    case presenting
}

/// The three phases of the single random-toast flow sheet.
///
/// `idle → (tap) pick + hold toast → prompt → [accept → loading → show(.full) → result]
///  OR [decline → result] → (닫기/swipe) idle`. An empty pick skips the flow
/// entirely and drives `presentedEmpty`.
enum RandomFlowPhase: Equatable {
    case prompt
    case loading
    case result
}

/// Drives the single `.sheet(item:)` for the random-toast flow.
///
/// `id` is stable for the sheet's life; `toast` is swapped in place by `reroll()`
/// and `phase` is advanced in place — neither re-presents the sheet. Views MUST
/// read the live value from `RandomToastCoordinator.presentedFlow`, not the
/// snapshot captured by `.sheet(item:)`'s content closure.
struct RandomFlow: Identifiable {
    let id = UUID()
    var toast: Toast
    let pool: RandomPool
    /// Pool size captured at pick time, fixed for the sheet's life.
    let poolCount: Int
    var phase: RandomFlowPhase
}

/// Drives the error `.sheet(item:)` (DB empty / category empty).
struct RandomEmptyPresentation: Identifiable, Equatable {
    let id = UUID()
    let error: RandomError
}

// MARK: - Coordinator

@MainActor
final class RandomToastCoordinator: ObservableObject {

    @Published private(set) var state: RandomRollState = .idle

    /// Drives `.sheet(item:)` for the flow surface (prompt / loading / result).
    @Published var presentedFlow: RandomFlow?
    /// Drives `.sheet(item:)` for the empty/error surface.
    @Published var presentedEmpty: RandomEmptyPresentation?

    /// Bumped on every shuffle tap — used as a `.sensoryFeedback` trigger.
    @Published private(set) var rollCount: Int = 0

    /// Cosmetic min-lock so the shuffle glyph finishes ~one spin and a
    /// double-tap can't slip through on an instant (local) path.
    private let minimumRollDuration: TimeInterval = 0.15

    // MARK: Entering the flow

    /// Tap of the 랜덤 button. Picks a toast synchronously, holds it, and either
    /// enters the `.prompt` phase or, for an empty pool, the empty surface.
    func start(pool: RandomPool, modelContext: ModelContext) {
        guard state == .idle else { return }

        state = .rolling
        rollCount += 1

        let outcome = pick(from: pool, excluding: nil, modelContext: modelContext)
        let count = poolCount(for: pool, modelContext: modelContext)

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(minimumRollDuration))

            switch outcome {
            case .success(let toast):
                presentedFlow = RandomFlow(
                    toast: toast,
                    pool: pool,
                    poolCount: count,
                    phase: .prompt
                )
                state = .presenting

            case .failure(let error):
                presentedEmpty = RandomEmptyPresentation(error: error)
                state = .presenting
            }
        }
    }

    // MARK: Phase transitions

    /// 광고 보고 뽑기 — prompt → loading. The actual `await adManager.show(.full)`
    /// is driven by the sheet (it owns the `@EnvironmentObject`); it calls
    /// `finishLoading()` when the ad returns (played or fast-false, same path).
    func beginLoading() {
        guard var flow = presentedFlow, flow.phase == .prompt else { return }
        flow.phase = .loading
        presentedFlow = flow
    }

    /// loading → result. Called after `show(.full)` returns, regardless of result.
    func finishLoading() {
        guard var flow = presentedFlow, flow.phase == .loading else { return }
        flow.phase = .result
        presentedFlow = flow
    }

    /// 취소 — aborts the draw entirely. The pre-picked toast is discarded and
    /// the sheet dismisses back to the originating screen. No toast, no ad.
    func decline() {
        guard let flow = presentedFlow, flow.phase == .prompt else { return }
        close()
    }

    // MARK: In-flow re-roll — never touches the ad manager, never changes phase

    func reroll(modelContext: ModelContext) {
        guard var flow = presentedFlow, flow.phase == .result else { return }
        guard flow.poolCount > 1 else { return }

        let outcome = pick(
            from: flow.pool,
            excluding: flow.toast.persistentModelID,
            modelContext: modelContext
        )

        if case .success(let toast) = outcome {
            flow.toast = toast
            presentedFlow = flow
        }
    }

    // MARK: Leaving the flow

    /// Called from the sheet's `.onDisappear` and from the empty surface's close.
    /// No ad is ever fired here (the old dismiss-time interstitial is gone).
    func close() {
        presentedFlow = nil
        presentedEmpty = nil
        state = .idle
    }

    // MARK: - Picking

    private enum PickOutcome {
        case success(Toast)
        case failure(RandomError)
    }

    private func pick(
        from pool: RandomPool,
        excluding excludedID: PersistentIdentifier?,
        modelContext: ModelContext
    ) -> PickOutcome {
        switch pool {
        case .all:
            let total = (try? modelContext.fetchCount(FetchDescriptor<Toast>())) ?? 0
            guard total > 0 else { return .failure(.emptyDatabase) }

            if total == 1 {
                var descriptor = FetchDescriptor<Toast>()
                descriptor.fetchLimit = 1
                if let toast = try? modelContext.fetch(descriptor).first {
                    return .success(toast)
                }
                return .failure(.emptyDatabase)
            }

            // A handful of random offsets is enough to avoid an immediate repeat.
            for _ in 0..<8 {
                var descriptor = FetchDescriptor<Toast>()
                descriptor.fetchOffset = Int.random(in: 0..<total)
                descriptor.fetchLimit = 1
                guard let toast = try? modelContext.fetch(descriptor).first else { continue }
                if toast.persistentModelID != excludedID { return .success(toast) }
            }

            // Fallback: pull everything and filter (toast set is small).
            let all = (try? modelContext.fetch(FetchDescriptor<Toast>())) ?? []
            let candidates = all.filter { $0.persistentModelID != excludedID }
            if let toast = (candidates.isEmpty ? all : candidates).randomElement() {
                return .success(toast)
            }
            return .failure(.emptyDatabase)

        case .category(let id):
            guard let category = modelContext.model(for: id) as? ToastCategory else {
                return .failure(.emptyPool)
            }
            let toasts = category.toasts
            guard !toasts.isEmpty else { return .failure(.emptyPool) }
            if toasts.count == 1 { return .success(toasts[0]) }

            let candidates = toasts.filter { $0.persistentModelID != excludedID }
            if let toast = (candidates.isEmpty ? toasts : candidates).randomElement() {
                return .success(toast)
            }
            return .failure(.emptyPool)
        }
    }

    private func poolCount(for pool: RandomPool, modelContext: ModelContext) -> Int {
        switch pool {
        case .all:
            return (try? modelContext.fetchCount(FetchDescriptor<Toast>())) ?? 0
        case .category(let id):
            guard let category = modelContext.model(for: id) as? ToastCategory else { return 0 }
            return category.toasts.count
        }
    }
}
