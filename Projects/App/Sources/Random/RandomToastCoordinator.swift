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
    /// Prompt dismissed on purpose, interstitial call in flight, no sheet
    /// visible. The interstitial cannot present while our sheet owns the root
    /// view controller, so the prompt must be gone before `show(.full)`.
    case awaitingAd
}

/// The two phases of the random-toast flow sheet. The prompt and the result are
/// separate `.sheet` presentations (the prompt is fully dismissed for the ad
/// call), so a single sheet instance only ever shows one phase.
///
/// `idle → (tap) pick + hold toast → prompt →
///   [accept → dismiss prompt → show(.full) → result sheet]
///   OR [decline → dismiss, nothing] → (닫기/swipe) idle`.
/// An empty pick skips the flow entirely and drives `presentedEmpty`.
enum RandomFlowPhase: Equatable {
    case prompt
    case result
}

/// Drives one of the flow `.sheet(item:)`s (`presentedPrompt` or
/// `presentedResult`).
///
/// `id` is stable for the sheet's life; `toast` is swapped in place by `reroll()`
/// — it does not re-present the sheet. Views MUST read the live value from the
/// matching `RandomToastCoordinator` binding, not the snapshot captured by
/// `.sheet(item:)`'s content closure.
struct RandomFlow: Identifiable {
    let id = UUID()
    var toast: Toast
    let pool: RandomPool
    /// Pool size captured at pick time, fixed for the sheet's life.
    let poolCount: Int
    /// Fixed per sheet instance — `.prompt` or `.result`.
    let phase: RandomFlowPhase
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

    /// Drives the prompt `.sheet(item:)`. Dismissed to `nil` before the ad call.
    @Published var presentedPrompt: RandomFlow?
    /// Drives the result `.sheet(item:)` — a *separate* presentation so the
    /// prompt's dismissal never trips the result sheet's `.onDisappear`, and the
    /// result can present cleanly after the prompt is fully gone.
    @Published var presentedResult: RandomFlow?
    /// Drives `.sheet(item:)` for the empty/error surface.
    @Published var presentedEmpty: RandomEmptyPresentation?

    /// `true` only while `adManager.show(.full)` is actually in flight — set
    /// right before the call, cleared right after. Drives the root loading
    /// overlay, which itself waits ~150ms so the no-ad fast path never flashes.
    @Published private(set) var isPresentingAd = false

    /// Bumped on every shuffle tap — used as a `.sensoryFeedback` trigger.
    @Published private(set) var rollCount: Int = 0

    /// Held toast/pool across the prompt-dismiss → ad → result-present gap,
    /// during which no sheet is visible.
    private var pendingDraw: PendingDraw?

    private struct PendingDraw {
        let toast: Toast
        let pool: RandomPool
        let poolCount: Int
    }

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
                presentedPrompt = RandomFlow(
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

    // MARK: The ad gap

    /// 광고 보고 뽑기 — dismiss the prompt sheet and stash the draw. The
    /// interstitial can't present while our sheet owns the root view controller,
    /// so the sheet must be gone before `adManager.show(.full)`. The sheet's
    /// accept `Task` drives the settle → ad → `revealPendingResult()` sequence.
    func beginAwaitingAd() {
        guard let flow = presentedPrompt else { return }
        pendingDraw = PendingDraw(toast: flow.toast, pool: flow.pool, poolCount: flow.poolCount)
        state = .awaitingAd
        presentedPrompt = nil
    }

    /// Set just before / after `adManager.show(.full)` so the root overlay only
    /// appears when the ad call is genuinely slow (i.e. an ad is presenting).
    func setPresentingAd(_ presenting: Bool) {
        isPresentingAd = presenting
    }

    /// Present the result as a fresh sheet once the ad call returns — whether an
    /// ad played (`true`) or it fast-failed (`false`), the next step is identical.
    func revealPendingResult() {
        guard state == .awaitingAd, let draw = pendingDraw else { return }
        isPresentingAd = false
        pendingDraw = nil
        presentedResult = RandomFlow(
            toast: draw.toast,
            pool: draw.pool,
            poolCount: draw.poolCount,
            phase: .result
        )
        state = .presenting
    }

    /// 취소 — aborts the draw entirely. The pre-picked toast is discarded and
    /// the sheet dismisses back to the originating screen. No toast, no ad.
    func decline() {
        guard presentedPrompt != nil else { return }
        close()
    }

    // MARK: In-flow re-roll — never touches the ad manager, never changes phase

    func reroll(modelContext: ModelContext) {
        guard var flow = presentedResult else { return }
        guard flow.poolCount > 1 else { return }

        let outcome = pick(
            from: flow.pool,
            excluding: flow.toast.persistentModelID,
            modelContext: modelContext
        )

        if case .success(let toast) = outcome {
            flow.toast = toast
            presentedResult = flow
        }
    }

    // MARK: Leaving the flow

    /// Called from the result sheet's `.onDisappear`, from 취소, and from the
    /// empty surface's close. No ad is ever fired here.
    func close() {
        presentedPrompt = nil
        presentedResult = nil
        presentedEmpty = nil
        pendingDraw = nil
        isPresentingAd = false
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
