//
//  PriceLabel.swift
//  alivium
//

import SwiftUI

/// Renders a product's price, with a strikethrough original price + accent-colored discount
/// price when on sale — the one place price formatting/discount styling happens, so it can't
/// drift between screens (CLAUDE.md 9.6).
struct PriceLabel: View {
    let price: Money
    var discountPrice: Money? = nil

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            if let discountPrice {
                Text(discountPrice.formatted)
                    .font(AppTypography.price)
                    .foregroundStyle(AppColor.accent)
                Text(price.formatted)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .strikethrough()
            } else {
                Text(price.formatted)
                    .font(AppTypography.price)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        PriceLabel(price: Money(189.00))
        PriceLabel(price: Money(349.00), discountPrice: Money(279.00))
    }
    .padding()
}
