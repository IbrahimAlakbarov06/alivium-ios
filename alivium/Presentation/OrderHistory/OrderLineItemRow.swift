//
//  OrderLineItemRow.swift
//  alivium
//

import SwiftUI

/// Read-only counterpart to `CartLineItemRow` — same image + name + variant + price layout, but
/// a plain "x2" quantity label instead of a `QuantityStepper`, and no remove button, since a
/// placed order's line items can't be edited.
///
/// Pushes Product Detail itself (an internal `NavigationLink`) rather than letting the caller
/// wrap the whole row, specifically so the "Rate Product" footer below can sit *outside* that
/// link's label as a true sibling. Nesting the rating `Button` inside the same `NavigationLink`
/// (as `CartLineItemRow`'s stepper/remove controls do successfully) was tried first, but here the
/// tap was reliably swallowed by the enclosing link — it opened Product Detail instead of Rate
/// Product. Rather than depend on that fragile nested-button-in-link resolution, the footer is
/// kept structurally separate so there's no ambiguity for the OS to resolve.
struct OrderLineItemRow: View {
    @Environment(LocalizationManager.self) private var localization
    let item: CartItem
    /// `nil` when the order isn't Delivered — no rating UI at all for any other status.
    var ratingState: RatingState? = nil

    enum RatingState {
        case notRated(onTap: () -> Void)
        case rated
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            NavigationLink(value: item.product) {
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
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let ratingState {
                ratingFooter(ratingState)
                    // Lines up under the text column, past the 64pt image + its spacing.
                    .padding(.leading, 64 + AppSpacing.md)
                    .padding(.top, AppSpacing.xxs)
            }
        }
    }

    @ViewBuilder
    private func ratingFooter(_ state: RatingState) -> some View {
        switch state {
        case .notRated(let onTap):
            Button(action: onTap) {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "star")
                    Text(localization.string(.rateProduct))
                }
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.primary)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("rateProductButton-\(item.product.id)")
        case .rated:
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "star.fill")
                    .foregroundStyle(AppColor.accent)
                Text(localization.string(.rated))
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)
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
        ),
        ratingState: .notRated(onTap: {})
    )
    .padding()
    .environment(LocalizationManager())
}
