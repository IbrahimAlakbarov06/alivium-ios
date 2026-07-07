//
//  ProductGrid.swift
//  alivium
//

import SwiftUI

/// The 2-column product grid shared by Category/Product Listing and Collection Detail — extracted
/// so both reuse one implementation (CLAUDE.md 9.6) instead of duplicating the
/// hidden-background-`NavigationLink` wiring a second time.
struct ProductGrid: View {
    let products: [Product]
    let isWishlisted: (Product) -> Bool
    let onToggleWishlist: (Product) -> Void
    /// Shown instead of the grid when filters have narrowed a non-empty base set down to
    /// nothing — distinct from a screen's own "empty" `ViewState` (nothing here at all), which
    /// the caller still handles separately with its own `EmptyStateView`.
    let noMatchesText: String

    var body: some View {
        if products.isEmpty {
            Text(noMatchesText)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.top, AppSpacing.xxl)
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible())],
                spacing: AppSpacing.lg
            ) {
                ForEach(products) { product in
                    // A hidden background link, not a wrapping one — wrapping `NavigationLink`
                    // around a `ProductCard` that contains its own real wishlist `Button` lets the
                    // two gestures race, so a tap only opens Product Detail intermittently instead
                    // of reliably on the first tap (see Home's rail for the original fix).
                    ProductCard(product: product, layout: .grid, isWishlisted: isWishlisted(product)) {
                        onToggleWishlist(product)
                    }
                    .background {
                        NavigationLink(value: product) { Color.clear }
                    }
                }
            }
            .padding(AppSpacing.md)
        }
    }
}

#Preview {
    ScrollView {
        ProductGrid(
            products: MockProductRepository.featuredProducts,
            isWishlisted: { _ in false },
            onToggleWishlist: { _ in },
            noMatchesText: "No products match your filters"
        )
    }
}
