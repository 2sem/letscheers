//
//  ToastDetailScreen.swift
//  letscheers
//

import SwiftUI
import SwiftData

// MARK: - Route Resolver

/// Resolves the `Hashable` navigation payload (toast numbers) back into models.
struct ToastDetailRoute: View {
    let toastNos: [Int16]
    let index: Int

    @Query private var matches: [Toast]

    init(toastNos: [Int16], index: Int) {
        self.toastNos = toastNos
        self.index = index
        let nos = toastNos
        _matches = Query(filter: #Predicate<Toast> { nos.contains($0.no) })
    }

    private var orderedToasts: [Toast] {
        let byNo = Dictionary(matches.map { ($0.no, $0) }, uniquingKeysWith: { first, _ in first })
        return toastNos.compactMap { byNo[$0] }
    }

    var body: some View {
        let toasts = orderedToasts
        if toasts.isEmpty {
            ContentUnavailableView("건배사가 없어요", systemImage: "wineglass")
        } else {
            ToastDetailScreen(toasts: toasts, startIndex: min(max(index, 0), toasts.count - 1))
        }
    }
}

// MARK: - Screen

/// "낭독 모드": the big read-aloud view for one toast, swipeable across a deck.
struct ToastDetailScreen: View {
    let toasts: [Toast]

    @State private var index: Int
    @State private var copyTick = 0
    @State private var showCopied = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(toasts: [Toast], startIndex: Int) {
        self.toasts = toasts
        _index = State(initialValue: startIndex)
    }

    private var current: Toast { toasts[min(index, toasts.count - 1)] }
    private var tint: Color { .categoryTint(for: current.category?.name) }

    var body: some View {
        pager
            .background { background }
            .safeAreaInset(edge: .bottom) { actionBar }
            .overlay(alignment: .bottom) { copiedBanner }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if toasts.count > 1 { counter }
                }
                ToolbarItem(placement: .topBarTrailing) { favoriteButton }
            }
            .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
            .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
            .sensoryFeedback(.success, trigger: copyTick)
    }

    // MARK: - Sections

    private var pager: some View {
        TabView(selection: $index) {
            ForEach(Array(toasts.enumerated()), id: \.element.no) { offset, toast in
                ToastDetailPage(toast: toast)
                    .tag(offset)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: index = min(index + 1, toasts.count - 1)
            case .decrement: index = max(index - 1, 0)
            @unknown default: break
            }
        }
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [tint.opacity(0.18), .appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
            RadialGradient(
                colors: [tint.opacity(0.14), .clear],
                center: .init(x: 0.5, y: 0.32),
                startRadius: 0,
                endRadius: 280
            )
        }
        .background(Color.appBackground)
        .ignoresSafeArea()
        .animation(reduceMotion ? nil : .smooth, value: current.no)
    }

    private var counter: some View {
        Text("\(index + 1) / \(toasts.count)")
            .font(.footnote)
            .foregroundStyle(Color.textSecondary)
            .monospacedDigit()
            .accessibilityLabel("\(toasts.count)개 중 \(index + 1)번째")
    }

    private var favoriteButton: some View {
        FavoriteStarButton(isFavorite: current.isFavorite) {
            current.toggleFavorite(in: modelContext)
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                UIPasteboard.general.string = current.plainText
                copyTick += 1
                flashCopied()
            } label: {
                Label("복사", systemImage: "doc.on.doc")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.surfaceElevated, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            ToastShareButton(toast: current) {
                Label("카드로 공유", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(Color.onGold)
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.accentGold, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
            .contextMenu {
                ShareLink(item: current.shareText) {
                    Label("텍스트로 공유", systemImage: "text.alignleft")
                }
            }
        }
        .frame(maxWidth: 480)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var copiedBanner: some View {
        if showCopied {
            Text("복사했어요")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.surfaceElevated))
                .overlay(Capsule().strokeBorder(Color.stroke))
                .padding(.bottom, 96)
                .transition(.opacity)
                .accessibilityHidden(true)
        }
    }

    private func flashCopied() {
        AccessibilityNotification.Announcement("복사했어요").post()
        withAnimation { showCopied = true }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation { showCopied = false }
        }
    }
}

// MARK: - Page

private struct ToastDetailPage: View {
    let toast: Toast

    @Environment(\.horizontalSizeClass) private var sizeClass
    @ScaledMetric(relativeTo: .largeTitle) private var phoneTitleSize: CGFloat = 48
    @ScaledMetric(relativeTo: .largeTitle) private var padTitleSize: CGFloat = 56

    private var presentation: ToastPresentation { ToastPresentation(title: toast.title, contents: toast.contents) }
    private var titleSize: CGFloat { sizeClass == .regular ? padTitleSize : phoneTitleSize }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 28) {
                    categoryChip
                    title
                    if presentation.hasCallAndResponse {
                        callAndResponse
                    }
                    if !presentation.meaning.isEmpty {
                        meaning
                    }
                }
                .frame(maxWidth: 640)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height * 0.9)
            }
        }
    }

    @ViewBuilder
    private var categoryChip: some View {
        if let name = toast.category?.name {
            let tint = Color.categoryTint(for: name)
            Text(name)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(tint)
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(Capsule().fill(tint.opacity(0.2)))
        }
    }

    @ViewBuilder
    private var title: some View {
        if presentation.hasTitleCallAndResponse {
            titleCallAndResponse
        } else {
            plainTitle
        }
    }

    private var titleCallAndResponse: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(presentation.titleLines) { line in
                VStack(alignment: .center, spacing: 8) {
                    RoleLabel(role: line.role)
                    Text(line.text)
                        .font(.system(size: titleSize, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(presentation.titleAccessibilityLabel)
        .accessibilityAddTraits(.isHeader)
    }

    private var plainTitle: some View {
        Text(toast.title)
            .font(.system(size: titleSize, weight: .heavy, design: .rounded))
            .foregroundStyle(.white)
            .minimumScaleFactor(0.5)
            .lineLimit(4)
            .multilineTextAlignment(.center)
            .accessibilityAddTraits(.isHeader)
    }

    private var callAndResponse: some View {
        VStack(alignment: .leading, spacing: 16) {
            divider
            ForEach(presentation.lines) { line in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    RoleLabel(role: line.role)
                    Text(line.text)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(line.role.rawValue), \(line.text)")
            }
            divider
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .accessibilityHidden(true)
    }

    private var meaning: some View {
        Text(presentation.meaning)
            .font(.title3)
            .foregroundStyle(Color.textSecondary)
            .multilineTextAlignment(.center)
    }
}
