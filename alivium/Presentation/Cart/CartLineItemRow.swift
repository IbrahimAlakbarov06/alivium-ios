//
//  CartLineItemRow.swift
//  alivium
//

import SwiftUI

struct CartLineItemRow: View {
    @Environment(LocalizationManager.self) private var localization
    let item: CartItem
    let onQuantityChange: (Int) -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: item.product.primaryImageName)
                .frame(width: 84, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
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

                HStack {
                    QuantityStepper(quantity: Binding(
                        get: { item.quantity },
                        set: onQuantityChange
                    ))

                    Spacer()

                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    .accessibilityLabel(localization.string(.removeItem))
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
}

#Preview {
    CartLineItemRow(
        item: CartItem(
            id: "cart-1",
            product: Product(
                id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                imageNames: [], categoryId: "dresses", variants: []
            ),
            selectedVariant: ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
            quantity: 2
        ),
        onQuantityChange: { _ in },
        onRemove: {}
    )
    .padding()
    .environment(LocalizationManager())
}
