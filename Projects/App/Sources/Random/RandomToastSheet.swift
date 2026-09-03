//
//  RandomToastSheet.swift
//  letscheers
//
//  Created by Claude Code on 2026. 9. 2.
//  Copyright © 2026 leesam. All rights reserved.
//

import SwiftUI
import SwiftData

/// The single flow surface for both entry points (home grid + category list).
///
/// One `.sheet(item:)` whose content crossfades between the three phases —
/// `.prompt` (opt-in), `.loading` (awaiting the interstitial), `.result` (the
/// reveal). The ad is only ever shown on the explicit `.prompt` → accept path,
/// with the frequency cap forced off since the user opted in. Re-roll never
/// touches the ad manager and never changes phase.
struct RandomToastSheet: View {
    /// Snapshot captured by `.sheet(item:)` — used only for `id` stability and
    /// as a fallback. The live value is read from the coordinator.
    let flow: RandomFlow

    @EnvironmentObject private var coordinator: RandomToastCoordinator
    @EnvironmentObject private var adManager: SwiftUIAdManager
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var detent: PresentationDetent = .height(300)
    @State private var isExpanded = false
    @State private var rerollLocked = false
    @State private var heroTick = 0
    @AccessibilityFocusState private var heroFocused: Bool

    // MARK: Live state

    private var live: RandomFlow { coordinator.presentedFlow ?? flow }
    private var phase: RandomFlowPhase { live.phase }
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
        case .prompt, .loading:
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
            .animation(phaseAnimation, value: phase)
            .onAppear {
                detent = promptDetent
                if isAccessibilitySize { isExpanded = true }
            }
            .onChange(of: phase) { _, newPhase in
                withAnimation(phaseAnimation) {
                    detent = (newPhase == .result) ? resultDetent : promptDetent
                }
                if newPhase == .result {
                    heroTick += 1
                    heroFocused = true
                }
            }
            .onChange(of: coordinator.presentedFlow?.toast.persistentModelID) { _, newID in
                guard newID != nil, phase == .result else { return }
                heroTick += 1
                heroFocused = true
                AccessibilityNotification.Announcement("새 건배사. \(liveToast.title)").post()
            }
            .onDisappear {
                coordinator.close()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .prompt:
            RandomAdPromptView(onAccept: acceptAd, onDecline: coordinator.decline)
                .transition(.opacity)
        case .loading:
            RandomLoadingView()
                .transition(.opacity)
        case .result:
            resultContent
                .transition(.opacity)
        }
    }

    private var phaseAnimation: Animation {
        reduceMotion ? .linear(duration: 0.15) : .smooth(duration: 0.3)
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

    /// 광고 보고 뽑기 — prompt → loading → `show(.full, force: true)` → result.
    /// The `false` fast-path (no ad / capped / LaunchCount ≤ 1) advances to the
    /// reveal identically, with no error or message.
    private func acceptAd() {
        coordinator.beginLoading()
        Task {
            // Minimum loading display so the phase never flashes.
            try? await Task.sleep(for: .seconds(0.35))
            _ = await adManager.show(unit: .full, force: true)
            // Short settle after the ad returns before the reveal.
            try? await Task.sleep(for: .seconds(0.2))
            coordinator.finishLoading()
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
