//
//  CatalogImage.swift
//  alivium
//

import SwiftUI
import UIKit

/// Loads a named asset from Assets.xcassets; falls back to a neutral placeholder when the
/// asset doesn't exist yet. Phase 1 sample data ships with the image *names* products/banners/
/// collections will use before the real photography has been added — this lets Home be built
/// and wired now, and the moment a matching asset is dropped into Assets.xcassets, it starts
/// rendering automatically with no code change.
struct CatalogImage: View {
    let name: String?

    var body: some View {
        content
            // Purely decorative — without this, `Image` swallows touches that land on it
            // instead of passing them through to a tap gesture/NavigationLink sitting behind
            // or around it (e.g. a card's hidden background link), unlike Text/Color which
            // already pass taps through when they carry no gesture of their own.
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private var content: some View {
        if let name, UIImage(named: name) != nil {
            // `scaledToFill()` alone crops to dead-center, which for portrait source photos in
            // small/square frames (Cart's 80x80 row thumbnail, a grid card) can cut off the actual
            // subject and leave mostly background. Anchoring the crop to the top keeps the
            // subject in frame instead, since these photos are all composed with their subject in
            // the upper two-thirds. `GeometryReader` is needed to know the frame the caller
            // actually assigned before `.clipped()` can crop to it.
            GeometryReader { proxy in
                Image(name)
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
                    .clipped()
            }
        } else {
            ZStack {
                AppColor.surface
                Image(systemName: "photo")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(AppColor.textSecondary.opacity(0.4))
            }
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        CatalogImage(name: nil)
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        CatalogImage(name: "DoesNotExistYet")
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    .padding()
}
