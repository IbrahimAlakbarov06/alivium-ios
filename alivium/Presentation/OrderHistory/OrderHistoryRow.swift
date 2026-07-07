//
//  OrderHistoryRow.swift
//  alivium
//

import SwiftUI

/// Order number + status badge on top, date placed underneath, thumbnail (first line item's
/// image) + item count + total along the bottom — everything a shopper needs to recognize an
/// order and its state before tapping in for the full breakdown.
struct OrderHistoryRow: View {
    @Environment(LocalizationManager.self) private var localization
    let order: Order

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            CatalogImage(name: order.items.first?.product.primaryImageName)
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("#\(order.orderNumber)")
                            .font(AppTypography.bodyEmphasis)
                            .foregroundStyle(AppColor.textPrimary)
                        Text(Self.dateFormatter.string(from: order.placedAt))
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    Spacer(minLength: AppSpacing.sm)
                    OrderStatusBadge(status: order.status)
                }

                HStack {
                    Text("\(order.itemCount) \(localization.string(.items))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    Text(order.total.formatted)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                }
                .padding(.top, AppSpacing.xxs)
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    /// A plain calendar date (matching `OrderConfirmationView`'s own delivery-range formatting)
    /// rather than routing through `LocalizationManager` — this app's AZ/EN toggle governs UI
    /// strings, not date formatting.
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

#Preview {
    OrderHistoryRow(
        order: Order(
            id: "order-1", orderNumber: "AL-58213",
            items: [
                CartItem(
                    id: "oi-1",
                    product: Product(
                        id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                        imageNames: [], categoryId: "dresses", variants: [],
                        description: "", averageRating: 4.7, reviewCount: 132
                    ),
                    selectedVariant: ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
                    quantity: 1
                )
            ],
            address: Address(
                id: "addr-1", label: "Home", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
                addressLine: "28 May küç. 15", city: "Bakı", postalCode: "AZ1000"
            ),
            shippingMethod: .standard, paymentMethod: .cashOnDelivery, status: .delivered,
            subtotal: Money(189.00), placedAt: Date()
        )
    )
    .padding()
    .background(AppColor.backgroundOffWhite)
    .environment(LocalizationManager())
}
