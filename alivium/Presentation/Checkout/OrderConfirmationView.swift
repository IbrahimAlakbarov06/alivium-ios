//
//  OrderConfirmationView.swift
//  alivium
//

import SwiftUI

/// Step 3 of Checkout — a terminal success state, so unlike Address/Payment there's no back
/// control at all, only a single way forward.
struct OrderConfirmationView: View {
    @Environment(LocalizationManager.self) private var localization
    let viewModel: CheckoutViewModel
    let orderNumber: String
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72, weight: .regular))
                .foregroundStyle(AppColor.primary)
                .accessibilityIdentifier("orderConfirmationCheckmark")

            Text(localization.string(.orderPlacedTitle))
                .font(AppTypography.display)
                .foregroundStyle(AppColor.textPrimary)

            Text(localization.string(.orderPlacedSubtitle))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)

            VStack(spacing: AppSpacing.sm) {
                summaryRow(title: localization.string(.orderNumberLabel), value: orderNumber)
                Divider()
                summaryRow(title: localization.string(.estimatedDeliveryLabel), value: estimatedDeliveryRangeText)
            }
            .padding(AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .padding(.horizontal, AppSpacing.md)

            Spacer()
            Spacer()

            BaseButton(title: localization.string(.backToHome), kind: .primary, size: .large) {
                onDone()
            }
            .accessibilityIdentifier("orderConfirmationBackToHomeButton")
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.backgroundOffWhite)
    }

    /// A believable delivery window (not just a single point estimate) derived from the chosen
    /// shipping method's day count — e.g. Standard (5 days) shows roughly "day 3 - day 5" from
    /// today, formatted as actual calendar dates.
    private var estimatedDeliveryRangeText: String {
        let days = viewModel.selectedShippingMethod.days
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: max(days - 2, 1), to: Date()) ?? Date()
        let endDate = calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
    }

    private func summaryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
}

#Preview {
    OrderConfirmationView(
        viewModel: CheckoutViewModel(
            items: [],
            selectedShippingMethod: .standard,
            addressRepository: MockAddressRepository(),
            cartRepository: MockCartRepository(),
            orderRepository: MockOrderRepository(),
            cartBadgeStore: CartBadgeStore()
        ),
        orderNumber: "AL-48213",
        onDone: {}
    )
    .environment(LocalizationManager())
}
