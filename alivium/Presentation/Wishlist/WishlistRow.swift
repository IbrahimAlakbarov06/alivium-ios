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
///
/// Layout note: the size dropdown + Add to Cart button live in their OWN full-width row below the
/// image/name/price row, not squeezed inside the text column next to the image. Putting them in
/// the text column repeatedly ran into SwiftUI's layout algorithm treating wrappable Text as more
/// "compressible" than a fixed-size Menu/Button, causing the name/price to wrap unpredictably
/// depending on button width. Giving the controls their own full-width row removes that fight
/// entirely — there's always enough room since nothing else shares that row.
struct WishlistRow: View {
    @Environment(LocalizationManager.self) private var localization
    let product: Product
    /// Empty for a single-variant product — the row then skips the dropdown entirely and shows
    /// just "Add to Cart", since there's nothing to choose.
    let availableSizes: [String]
    let selectedSize: String?
    let canAddToCart: Bool
    let isAddingToCart: Bool
    let didAddToCart: Bool
    let onRemove: () -> Void
    let onSelectSize: (String) -> Void
    let onAddToCart: () -> Void

    /// Captures the measured height of the name/price/controls column so the image can be
    /// stretched to match it exactly, instead of guessing a fixed height — avoids the empty gap
    /// that appears whenever the fixed-height image is shorter than the column beside it.
    private struct ContentHeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 88
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = max(value, nextValue())
        }
    }

    @State private var contentHeight: CGFloat = 88

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: product.primaryImageName)
                .frame(width: 88, height: contentHeight)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                PriceLabel(price: product.price, discountPrice: product.discountPrice)
                    .padding(.top, 2)

                Spacer(minLength: AppSpacing.sm)

                // Inline, row-level control (Trendyol-style) rather than a sheet/dialog over the
                // whole screen — the size dropdown sits directly beside Add to Cart so picking a
                // size and adding stay in the same glance.
                HStack(spacing: AppSpacing.sm) {
                    // 0 or 1 variant total has nothing to choose between — skip the dropdown
                    // entirely, matching Product Detail's own "nothing to choose" behavior.
                    if product.variants.count > 1 {
                        sizeMenu
                    }

                    BaseButton(
                        title: didAddToCart ? localization.string(.addedToCart) : localization.string(.addToCart),
                        kind: .primary,
                        size: .small,
                        isLoading: isAddingToCart,
                        isEnabled: canAddToCart
                    ) {
                        onAddToCart()
                    }
                }
            }
            .background(
                GeometryReader { proxy in
                    Color.clear.preference(key: ContentHeightKey.self, value: proxy.size.height)
                }
            )

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
        .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    /// Compact dropdown, not a full-screen sheet/dialog — tap to reveal the size options inline,
    /// with the label itself doubling as the current selection (or a placeholder until one is
    /// picked), matching the reference row layout.
    private var sizeMenu: some View {
        Menu {
            ForEach(availableSizes, id: \.self) { size in
                Button(size) { onSelectSize(size) }
            }
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Text(selectedSize ?? localization.string(.sizePlaceholder))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            // Without this, `Menu` renders its custom label at the system's default (much
            // taller/wider) tap-target size instead of hugging the label's own compact content —
            // this was diagnosed and fixed once before; keeping it here so it can't regress.
            .fixedSize()
        }
        .accessibilityIdentifier("wishlistRowSizeMenu-\(product.id)")
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        WishlistRow(
            product: Product(
                id: "preview", name: "Structured Leather Tote", price: Money(259.00), discountPrice: nil,
                imageNames: [], categoryId: "bags",
                variants: [
                    ProductVariant(id: "Cognac-S", size: "S", color: "Cognac", stockQuantity: 8),
                    ProductVariant(id: "Cognac-M", size: "M", color: "Cognac", stockQuantity: 8)
                ],
                description: "A structured leather tote.", averageRating: 4.6, reviewCount: 88
            ),
            availableSizes: ["S", "M"],
            selectedSize: nil,
            canAddToCart: false,
            isAddingToCart: false,
            didAddToCart: false,
            onRemove: {},
            onSelectSize: { _ in },
            onAddToCart: {}
        )

        WishlistRow(
            product: Product(
                id: "preview2", name: "Suede Ankle Boots", price: Money(219.00), discountPrice: Money(175.00),
                imageNames: [], categoryId: "shoes",
                variants: [
                    ProductVariant(id: "Beige-38", size: "38", color: "Beige", stockQuantity: 4)
                ],
                description: "Suede ankle boots.", averageRating: 4.8, reviewCount: 54
            ),
            availableSizes: [],
            selectedSize: nil,
            canAddToCart: true,
            isAddingToCart: false,
            didAddToCart: false,
            onRemove: {},
            onSelectSize: { _ in },
            onAddToCart: {}
        )
    }
    .padding()
    .background(AppColor.backgroundOffWhite)
    .environment(LocalizationManager())
}
