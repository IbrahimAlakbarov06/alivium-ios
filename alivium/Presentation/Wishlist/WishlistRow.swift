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

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // `.fit` (not the usual grid/rail `.fill` crop) — a saved item's own photo matters
            // more here than a uniform thumbnail, so the whole product should stay visible.
            CatalogImage(name: product.primaryImageName, contentMode: .fit)
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                PriceLabel(price: product.price, discountPrice: product.discountPrice)
                    .padding(.top, 2)

                // Inline, row-level control (Trendyol-style) rather than a sheet/dialog over the
                // whole screen — the size dropdown sits directly beside Add to Cart so picking a
                // size and adding stay in the same glance.
                HStack(spacing: AppSpacing.xs) {
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
                        isEnabled: canAddToCart,
                        // Fixed floor so the pill doesn't visibly resize switching between the
                        // "Add to Cart"/"Added to Cart" states, in either language — sized to fit
                        // the longest of the four (AZ "Səbətə əlavə edildi" is the widest).
                        minWidth: 150
                    ) {
                        onAddToCart()
                    }
                }
                .padding(.top, AppSpacing.sm)
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
            // `Menu` otherwise renders its custom label at the system menu-button's default
            // (much taller) tap-target size instead of hugging this label's own content — this
            // forces it back to its intrinsic size, matching a plain `Button`'s label.
            .fixedSize()
        }
        .accessibilityIdentifier("wishlistRowSizeMenu-\(product.id)")
    }
}

#Preview {
    WishlistRow(
        product: Product(
            id: "preview", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
            imageNames: [], categoryId: "dresses",
            variants: [
                ProductVariant(id: "Ivory-S", size: "S", color: "Ivory", stockQuantity: 8),
                ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
                ProductVariant(id: "Ivory-L", size: "L", color: "Ivory", stockQuantity: 8)
            ],
            description: "A fluid silk wrap dress.", averageRating: 4.7, reviewCount: 132
        ),
        availableSizes: ["S", "M", "L"],
        selectedSize: nil,
        canAddToCart: false,
        isAddingToCart: false,
        didAddToCart: false,
        onRemove: {},
        onSelectSize: { _ in },
        onAddToCart: {}
    )
    .padding()
    .background(AppColor.backgroundOffWhite)
    .environment(LocalizationManager())
}
