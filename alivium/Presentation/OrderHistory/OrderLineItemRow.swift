//
//  OrderLineItemRow.swift
//  alivium
//

import SwiftUI

/// Read-only counterpart to `CartLineItemRow` — same image + name + variant + price layout, but
/// a plain "x2" quantity label instead of a `QuantityStepper`, and no remove button, since a
/// placed order's line items can't be edited.
struct OrderLineItemRow: View {
    let item: CartItem

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: item.product.primaryImageName)
                .frame(width: 64, height: 64)
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

                HStack {
                    PriceLabel(price: item.product.price, discountPrice: item.product.discountPrice)
                    Spacer()
                    Text("x\(item.quantity)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }
                .padding(.top, 2)
            }
        }
    }
}

#Preview {
    OrderLineItemRow(
        item: CartItem(
            id: "oi-1",
            product: Product(
                id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                imageNames: [], categoryId: "dresses", variants: [],
                description: "", averageRating: 4.7, reviewCount: 132
            ),
            selectedVariant: ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
            quantity: 2
        )
    )
    .padding()
}
