//
//  ProductCard.swift
//  alivium
//

import SwiftUI

enum ProductCardLayout {
    /// Fixed-width card for a horizontal-scrolling rail.
    case rail
    /// Flexible-width card for a 2-column listing grid (Category screen, later).
    case grid
    /// Landscape image + details beside it — used to break up visual monotony when two rails
    /// would otherwise sit back-to-back with identical card treatment.
    case wide
}

/// One product card, styled by `layout` — never redefine this per screen (CLAUDE.md 9.6).
struct ProductCard: View {
    let product: Product
    var layout: ProductCardLayout = .rail
    /// Wishlist screen passes `true` since everything shown there is, by definition, saved.
    var isWishlisted: Bool = false
    var onTapWishlist: (() -> Void)? = nil

    var body: some View {
        switch layout {
        case .grid, .rail:
            verticalCard
        case .wide:
            wideCard
        }
    }

    private var verticalCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            imageWithWishlist
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            Text(product.name)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            PriceLabel(price: product.price, discountPrice: product.discountPrice)
        }
        .frame(width: layout == .rail ? 158 : nil)
    }

    private var wideCard: some View {
        HStack(spacing: AppSpacing.md) {
            imageWithWishlist
                .frame(width: 110, height: 110)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                PriceLabel(price: product.price, discountPrice: product.discountPrice)
            }

            Spacer(minLength: 0)
        }
        .frame(width: 260)
    }

    @ViewBuilder
    private var imageWithWishlist: some View {
        ZStack(alignment: .topTrailing) {
            CatalogImage(name: product.primaryImageName)

            if let onTapWishlist {
                Button(action: onTapWishlist) {
                    Image(systemName: isWishlisted ? "heart.fill" : "heart")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(isWishlisted ? AppColor.accent : AppColor.textPrimary)
                        .padding(AppSpacing.xs)
                        .background(AppColor.background.opacity(0.85))
                        .clipShape(Circle())
                }
                .padding(AppSpacing.xs)
                .accessibilityIdentifier(isWishlisted ? "wishlistHeartFilled" : "wishlistHeartOutline")
            }
        }
    }
}

#Preview {
    let sample = Product(
        id: "preview", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: Money(149.00),
        imageNames: [], categoryId: "dresses", variants: []
    )
    return ScrollView(.horizontal) {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ProductCard(product: sample, layout: .rail, onTapWishlist: {})
            ProductCard(product: sample, layout: .wide, onTapWishlist: {})
        }
        .padding()
    }
}
