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
            // Shrunk from 100x100 to free up the width the size menu + a consistently-sized Add
            // to Cart button need below — at 100x100 there wasn't enough row width left for both
            // without squeezing the name/price text into wrapping (see the `minWidth`s below).
            CatalogImage(name: product.primaryImageName)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                // `minWidth` on name/price counteracts a SwiftUI quirk in this leading VStack:
                // without it, wrappable `Text` is treated as the most "flexible" child and gets
                // squeezed first to make room for the size menu/button below (which refuse to
                // shrink, via `fixedSize()`/`minWidth`) — even when there's technically enough
                // shared width. This floors these two at the widest name/price we ship so they
                // stop absorbing that squeeze.
                Text(product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                    .frame(minWidth: 185, alignment: .leading)

                PriceLabel(price: product.price, discountPrice: product.discountPrice)
                    .padding(.top, 2)
                    .frame(minWidth: 185, alignment: .leading)

                // Bigger, intentional-looking gap below the price than the previous cramped
                // padding. Not a true bottom-anchor: this VStack sits in a ScrollView (unbounded
                // height), where a bare `Spacer()` doesn't get extra space to distribute the way
                // it would in a fixed-height container — it was tried and it broke this row's
                // layout — so this just guarantees a floor, same as a plain top padding would.
                Spacer(minLength: AppSpacing.md)

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
                        // Fixed floor, not content-hugging — without it, the pill's width tracks
                        // whichever of the four (2 states x 2 languages) strings is showing, so
                        // it visibly resizes on state/language change and AZ's "Səbətə əlavə
                        // edildi" (the widest, ~139pt including this padding) reads as oversized
                        // next to EN's much shorter "Added to Cart". 140 comfortably covers that
                        // widest string so every state/language renders the same considered size.
                        minWidth: 140
                    ) {
                        onAddToCart()
                    }
                }
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
            // forces it back to its intrinsic size, matching a plain `Button`'s label. Needed now
            // that the sibling Add to Cart button's `minWidth` leaves this less horizontal room
            // to get squeezed into that broken tall/narrow default.
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
