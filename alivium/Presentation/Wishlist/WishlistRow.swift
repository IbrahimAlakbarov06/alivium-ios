//
//  WishlistRow.swift
//  alivium
//

import SwiftUI

/// Horizontal row treatment for a saved item — image, name/price, and a direct "Add to Cart"
/// action, plus a heart in the trailing corner to un-save it. Mirrors `CartLineItemRow`'s
/// structure rather than reusing `ProductCard`, since this needs its own Add to Cart action that
/// ProductCard's model doesn't carry. The caller wraps this whole row directly in a
/// `NavigationLink` (see `ProductCard`'s heart comment) — a hidden background link here was
/// found not to reliably navigate at all (even tapping the plain name text did nothing), so this
/// uses the same wrapping approach already proven to work for every other product card/row.
struct WishlistRow: View {
    @Environment(LocalizationManager.self) private var localization
    let product: Product
    let isAddingToCart: Bool
    let didAddToCart: Bool
    let onRemove: () -> Void
    let onAddToCart: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: product.primaryImageName)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                PriceLabel(price: product.price, discountPrice: product.discountPrice)
                    .padding(.top, 2)

                BaseButton(
                    title: didAddToCart ? localization.string(.addedToCart) : localization.string(.addToCart),
                    kind: .primary,
                    size: .small,
                    isLoading: isAddingToCart
                ) {
                    onAddToCart()
                }
                .padding(.top, AppSpacing.xs)
            }

            Spacer(minLength: 0)

            Button(action: onRemove) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColor.accent)
            }
            // Scoped per-product (unlike `ProductCard`'s generic "wishlistHeartFilled") — Home's
            // rail can show the same seeded products with a filled heart too, and `TabView` keeps
            // every tab's view mounted (even off-screen), so a bare "wishlistHeartFilled" query
            // from a UI test can't tell this screen's row apart from Home's off-screen copy.
            .accessibilityIdentifier("wishlistRowHeart-\(product.id)")
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

#Preview {
    WishlistRow(
        product: Product(
            id: "preview", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
            imageNames: [], categoryId: "dresses", variants: [],
            description: "A fluid silk wrap dress.", averageRating: 4.7, reviewCount: 132
        ),
        isAddingToCart: false,
        didAddToCart: false,
        onRemove: {},
        onAddToCart: {}
    )
    .padding()
    .background(AppColor.backgroundOffWhite)
    .environment(LocalizationManager())
}
