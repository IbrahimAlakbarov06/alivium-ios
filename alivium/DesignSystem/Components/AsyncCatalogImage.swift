//
//  AsyncCatalogImage.swift
//  alivium
//

import SwiftUI
import UIKit

/// Phase 2 counterpart to `CatalogImage` (which only ever reads `Assets.xcassets`) — loads a
/// product photo from a remote URL through `ImageCache`, showing a shimmer placeholder while the
/// first fetch is in flight. Not wired into any product grid yet: there are no real backend image
/// URLs to point it at until Phase 2's networking lands, so `CatalogImage`'s asset-based behavior
/// stays untouched and this is exercised only by its own preview/tests for now.
struct AsyncCatalogImage: View {
    let url: URL?
    /// Same meaning as `CatalogImage.contentMode` — `.fill` for uniform grid/rail cells, `.fit`
    /// to letterbox a full garment/bag on `AppColor.surface` without cropping it.
    var contentMode: ContentMode = .fill

    @State private var loadedImage: UIImage?
    @State private var didFail = false

    var body: some View {
        content
            // `.task(id:)` cancels the in-flight load automatically the moment this cell scrolls
            // off-screen (or `url` changes to a different product) — a fast scroll through a
            // product grid shouldn't leave a pile of abandoned downloads racing to completion.
            .task(id: url) {
                await load()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let loadedImage {
            image(loadedImage)
        } else if didFail || url == nil {
            placeholder
        } else {
            placeholder
                .shimmering()
        }
    }

    @ViewBuilder
    private func image(_ uiImage: UIImage) -> some View {
        switch contentMode {
        case .fill:
            GeometryReader { proxy in
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                    .clipped()
            }
        case .fit:
            ZStack {
                AppColor.surface
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    private var placeholder: some View {
        ZStack {
            AppColor.surface
            Image(systemName: "photo")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(AppColor.textSecondary.opacity(0.4))
        }
        // Same reasoning as `CatalogImage` — decorative only, taps should pass through to
        // whatever card/link sits behind this cell.
        .allowsHitTesting(false)
    }

    private func load() async {
        guard let url else {
            didFail = false
            loadedImage = nil
            return
        }

        didFail = false
        loadedImage = nil

        if let cached = await ImageCache.shared.cachedImage(for: url) {
            loadedImage = cached
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard !Task.isCancelled else { return }

            guard let decoded = await Self.decode(data) else {
                didFail = true
                return
            }
            guard !Task.isCancelled else { return }

            loadedImage = decoded
            await ImageCache.shared.store(decoded, data: data, for: url)
        } catch {
            guard !Task.isCancelled else { return }
            didFail = true
        }
    }

    /// `UIImage(data:)` alone doesn't decompress the image — that happens lazily the first time
    /// it's drawn, which would land squarely on the main thread the moment this cell renders.
    /// `preparingForDisplay()` forces that decode eagerly, so it's done here, off the main thread.
    private static func decode(_ data: Data) async -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        return await Task.detached(priority: .userInitiated) {
            image.preparingForDisplay() ?? image
        }.value
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        AsyncCatalogImage(url: URL(string: "https://picsum.photos/seed/alivium1/400/400"))
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        AsyncCatalogImage(url: nil)
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    .padding()
}
