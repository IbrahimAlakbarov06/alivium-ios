//
//  CartLineItemRow.swift
//  alivium
//

import SwiftUI

/// Image + details (tappable, pushes Product Detail) with remove tucked into the top-trailing
/// corner (small, muted, out of the way) and the quantity stepper anchored under the price — so
/// the two controls sit apart diagonally instead of competing for attention on the same line.
struct CartLineItemRow: View {
    @Environment(LocalizationManager.self) private var localization
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: item.product.primaryImageName)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(item.product.name)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                if let variant = item.selectedVariant {
                    Text("\(variant.size) · \(variant.color)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                PriceLabel(price: item.product.price, discountPrice: item.product.discountPrice)
                    .padding(.top, 2)

                QuantityStepper(quantity: Binding(
                    get: { item.quantity },
                    set: onQuantityChange
                ))
                .padding(.top, AppSpacing.xs)
            }

            Spacer(minLength: 0)

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColor.textSecondary.opacity(0.55))
            }
            .accessibilityLabel(localization.string(.removeItem))
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
        // A hidden background link, not a wrapping one — the stepper and remove button above
        // stay plain, un-nested `Button`s instead of being embedded inside another interactive
        // control's accessibility subtree (see `ProductCard`'s heart for why that's avoided).
        .background {
            // `Color.clear`, not `EmptyView()` — EmptyView has zero intrinsic size, so the link
            // had no actual tappable area at all despite sitting in `.background`.
            NavigationLink(value: item.product) { Color.clear }
        }
    }
}

#Preview {
    CartLineItemRow(
        item: CartItem(
            id: "cart-1",
            product: Product(
                id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                imageNames: [], categoryId: "dresses", variants: [],
                description: "A fluid silk wrap dress.", averageRating: 4.7, reviewCount: 132
            ),
            selectedVariant: ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
            quantity: 2
        ),
        onQuantityChange: { _ in },
        onRemove: {}
    )
    .padding()
    .background(AppColor.backgroundOffWhite)
    .environment(LocalizationManager())
}
