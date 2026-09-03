//
//  RandomToastSheet.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

/// The flow surface for both entry points (home grid + category list).
///
/// A single sheet instance shows exactly one phase: `.prompt` (opt-in) or
/// `.result` (the reveal). Accepting the ad fully dismisses the prompt sheet —
/// the interstitial needs the root view controller — then the result is
/// presented as a fresh sheet after `show(.full)` returns. The wait indicator
/// during the ad call lives on the root (`RandomAdWaitingOverlay`), not here.
/// Re-roll never touches the ad manager.
struct RandomToastSheet: View {
    /// Snapshot captured by `.sheet(item:)` — used only for `id` stability and
    /// as a fallback. The live value is read from the coordinator.
    let flow: RandomFlow

    @EnvironmentObject private var coordinator: RandomToastCoordinator
    @EnvironmentObject private var adManager: SwiftUIAdManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var detent: PresentationDetent = .height(300)
    @State private var isExpanded = false
    @State private var rerollLocked = false
    @State private var heroTick = 0
    @AccessibilityFocusState private var heroFocused: Bool

    // MARK: Live state

    /// This instance is either the prompt sheet or the result sheet — `flow.phase`
    /// is fixed for its life. Read the live value from the matching coordinator
    /// binding so a re-roll's in-place toast swap is picked up.
    private var live: RandomFlow {
        switch flow.phase {
        case .prompt: return coordinator.presentedPrompt ?? flow
        case .result: return coordinator.presentedResult ?? flow
        }
    }
    private var phase: RandomFlowPhase { flow.phase }
    private var liveToast: Toast { live.toast }

    private var isAccessibilitySize: Bool { dynamicTypeSize >= .accessibility1 }
    private var useScroll: Bool { isExpanded || isAccessibilitySize }

    /// One fixed detent per phase — the sheet is not resizable. Swipe-down to
    /// dismiss still works on `.result` (interactive dismiss is enabled there).
    private var detents: Set<PresentationDetent> {
        [currentDetent]
    }

    private var currentDetent: PresentationDetent {
        switch phase {
        case .prompt:
            return promptDetent
        case .result:
            return resultDetent
        }
    }

    private var promptDetent: PresentationDetent {
        isAccessibilitySize ? .medium : .height(300)
    }

    private var resultDetent: PresentationDetent {
        // A single detent that clears the hero + action bar at default text
        // size; `.large` at accessibility sizes where the content scrolls.
        isAccessibilitySize ? .large : .fraction(0.65)
    }

    private var subtitle: String? {
        switch live.pool {
        case .all:
            return "전체 건배사 중에서"
        case .category:
            return liveToast.category.map { "'\($0.name)' 중에서" }
        }
    }

    // MARK: Body

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.cardBackground)
            .presentationDetents(detents, selection: $detent)
            .presentationDragIndicator(.hidden)
            .presentationBackground(Color.cardBackground)
            .presentationCornerRadius(24)
            .interactiveDismissDisabled(phase != .result)
            .sensoryFeedback(.impact(weight: .light), trigger: heroTick)
            .onAppear {
                detent = currentDetent
                if isAccessibilitySize { isExpanded = true }
                if phase == .result {
                    heroTick += 1
                    heroFocused = true
                }
            }
            .onChange(of: coordinator.presentedResult?.toast.persistentModelID) { _, newID in
                guard newID != nil, phase == .result else { return }
                heroTick += 1
                heroFocused = true
                AccessibilityNotification.Announcement("새 건배사. \(liveToast.title)").post()
            }
            .onDisappear {
                // Only the result sheet resets on dismiss. The prompt is torn
                // down either by 취소 (already `close()`d) or by 광고 보고 뽑기
                // (the accept `Task` owns the flow), so it must not `close()`
                // here — that would wipe the result the Task is about to present.
                if phase == .result {
                    coordinator.close()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .prompt:
            RandomAdPromptView(onAccept: acceptAd, onDecline: coordinator.decline)
        case .result:
            resultContent
        }
    }

    // MARK: Result phase

    private var resultContent: some View {
        VStack(spacing: 0) {
            header

            Spacer(minLength: 8)

            heroContainer

            Spacer(minLength: 8)

            RandomActionBar(
                toast: liveToast,
                poolCount: live.poolCount,
                isRerollLocked: rerollLocked,
                onReroll: reroll,
                onToggleFavorite: toggleFavorite
            )
            .padding(.bottom, 16)

            closeRow
        }
        .padding(.horizontal, 16)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("랜덤 건배사")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityElement(children: .combine)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("닫기")
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var heroContainer: some View {
        let hero = RandomToastHeroView(
            toast: liveToast,
            showCategoryChip: live.pool == .all,
            isExpanded: $isExpanded
        )
        .accessibilityFocused($heroFocused)

        if useScroll {
            ScrollView {
                hero.padding(.vertical, 8)
            }
        } else {
            hero
        }
    }

    private var closeRow: some View {
        Button {
            dismiss()
        } label: {
            Text("닫기")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: Actions

    /// 광고 보고 뽑기 — dismiss the prompt, wait for it to clear, show the
    /// interstitial, then present the result as a fresh sheet. The `false`
    /// fast-path (no ad / capped / LaunchCount ≤ 1) reaches the reveal
    /// identically, with no error or message.
    ///
    /// The `Task` is unstructured on purpose: it must outlive this view, which
    /// is torn down the moment `beginAwaitingAd()` clears `presentedPrompt`.
    private func acceptAd() {
        coordinator.beginAwaitingAd()
        Task { @MainActor in
            // Wait out the prompt sheet's full dismiss transition — presenting a
            // new sheet mid-dismiss leaves SwiftUI with a stuck dimming scrim.
            try? await Task.sleep(for: .seconds(0.65))
            coordinator.setPresentingAd(true)
            _ = await adManager.show(unit: .full, force: true)
            coordinator.setPresentingAd(false)
            // Let the wait overlay clear before the result sheet presents.
            try? await Task.sleep(for: .seconds(0.3))
            coordinator.revealPendingResult()
        }
    }

    private func reroll() {
        guard !rerollLocked else { return }
        rerollLocked = true
        withAnimation(.smooth(duration: 0.28)) {
            coordinator.reroll(modelContext: modelContext)
        }
        Task {
            try? await Task.sleep(for: .milliseconds(250))
            rerollLocked = false
        }
    }

    private func toggleFavorite() {
        let toast = liveToast
        if let favorite = toast.favorite {
            modelContext.delete(favorite)
            toast.favorite = nil
        } else {
            let favorite = Favorite(toast: toast)
            modelContext.insert(favorite)
            toast.favorite = favorite
        }
        try? modelContext.save()
    }
}
