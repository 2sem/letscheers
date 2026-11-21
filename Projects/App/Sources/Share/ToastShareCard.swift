//
//  ToastShareCard.swift
//  letscheers
//

import SwiftUI
import UniformTypeIdentifiers

/// PNG payload for `ShareLink`. Exported as a bare image: Kakao and Messages drop
/// the image when a URL rides along in the same item, so the App Store link goes
/// in the share *message* instead.
struct ToastShareCard: Transferable {
    let pngData: Data
    let preview: Image

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { card in
            card.pngData
        }
    }
}

// MARK: - Renderer

enum ToastShareRenderer {
    /// 1080x1350 px (360x450 pt at 3x). Must run on the main actor.
    @MainActor
    static func renderUIImage(for toast: Toast) -> UIImage? {
        let renderer = ImageRenderer(content: ShareCardView(toast: toast))
        renderer.scale = 3
        return renderer.uiImage
    }

    @MainActor
    static func renderCard(for toast: Toast) -> ToastShareCard? {
        guard let image = renderUIImage(for: toast),
              let data = image.pngData() else { return nil }
        return ToastShareCard(pngData: data, preview: Image(uiImage: image))
    }
}

// MARK: - Share Button

/// A `ShareLink` that shares the rendered card image once ready and falls back to
/// plain text until then (or if rendering fails).
struct ToastShareButton<Label: View>: View {
    let toast: Toast
    @ViewBuilder let label: () -> Label

    @State private var card: ToastShareCard?

    private static var message: Text {
        Text("술마셔 건배사 \(AppLinks.appStore.absoluteString)")
    }

    var body: some View {
        Group {
            if let card {
                ShareLink(
                    item: card,
                    message: Self.message,
                    preview: SharePreview(toast.title, image: card.preview),
                    label: label
                )
            } else {
                ShareLink(item: toast.shareText, label: label)
            }
        }
        .task(id: toast.no) {
            card = ToastShareRenderer.renderCard(for: toast)
        }
    }
}

// MARK: - Direct presenter

/// Opens the system share sheet with the card image straight away (swipe action
/// and context menu, where a `ShareLink` cannot live).
enum ToastSharePresenter {
    @MainActor
    static func present(_ toast: Toast) {
        let items: [Any]
        if let image = ToastShareRenderer.renderUIImage(for: toast) {
            items = [image]
        } else {
            items = [toast.shareText]
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var presenter = rootVC
        while let presented = presenter.presentedViewController { presenter = presented }
        activityVC.popoverPresentationController?.sourceView = presenter.view
        presenter.present(activityVC, animated: true)
    }
}
