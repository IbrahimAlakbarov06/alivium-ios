//
//  CollectionCard.swift
//  alivium
//

import SwiftUI

/// Large tappable image card with a title + item count overlaid on a bottom gradient scrim —
/// Home's "Top Collections" grid, and Discover's large category banners later (CLAUDE.md),
/// share this exact shape.
struct CollectionCard: View {
    let collection: ProductCollection
    var aspectRatio: CGFloat = 4.0 / 5.0
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                CatalogImage(name: collection.imageName)

                LinearGradient(
                    colors: [.black.opacity(0), .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(collection.name)
                        .font(AppTypography.headline)
                        .foregroundStyle(.white)
                    Text("\(collection.productCount) items")
                        .font(AppTypography.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .padding(AppSpacing.md)
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CollectionCard(
        collection: ProductCollection(id: "c-1", name: "The Autumn Edit", imageName: "Collection1", productCount: 24, description: "Considered pieces for the new season."),
        action: {}
    )
    .frame(width: 180)
    .padding()
}
