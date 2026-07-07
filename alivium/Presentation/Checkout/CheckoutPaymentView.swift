//
//  CheckoutPaymentView.swift
//  alivium
//

import SwiftUI

/// Step 2 of Checkout. Shipping stays re-selectable here (carried over from Cart, not lost) since
/// reconsidering delivery speed alongside payment is a normal checkout moment — the same
/// `ShippingMethod.allCases` radio-row pattern Cart itself uses, re-bound to
/// `CheckoutViewModel.selectedShippingMethod` instead of `CartViewModel`'s copy.
struct CheckoutPaymentView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: CheckoutViewModel
    let onBack: () -> Void
    let onPlaceOrder: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    shippingSection
                    paymentSection
                    summarySection
                }
                .padding(AppSpacing.md)
            }
            placeOrderButton
                .padding(AppSpacing.md)
        }
        .background(AppColor.backgroundOffWhite)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .accessibilityIdentifier("checkoutBackButton")
                Spacer()
            }

            Text(localization.string(.checkoutPaymentTitle))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
    }

    // MARK: - Shipping

    private var shippingSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(localization.string(.shippingSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.xxs) {
                ForEach(ShippingMethod.allCases) { method in
                    shippingRow(method)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func shippingRow(_ method: ShippingMethod) -> some View {
        let isSelected = viewModel.selectedShippingMethod == method

        return Button {
            viewModel.selectedShippingMethod = method
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.textSecondary.opacity(0.35))

                VStack(alignment: .leading, spacing: 2) {
                    Text(shippingName(for: method))
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(method.days) \(localization.string(.shippingDaysSuffix))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                if method.price.minorUnits > 0 {
                    Text(method.price.formatted)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.sm)
            .background(isSelected ? AppColor.primary.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("checkoutShippingRow-\(method.rawValue)")
    }

    private func shippingName(for method: ShippingMethod) -> String {
        switch method {
        case .free: return localization.string(.shippingFree)
        case .standard: return localization.string(.shippingStandard)
        case .fast: return localization.string(.shippingFast)
        }
    }

    // MARK: - Payment method

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(localization.string(.paymentMethodSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.xxs) {
                paymentRow(.cashOnDelivery, title: localization.string(.cashOnDelivery), icon: "banknote")
                paymentRow(.card, title: localization.string(.creditDebitCard), icon: "creditcard")
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func paymentRow(_ method: PaymentMethod, title: String, icon: String) -> some View {
        let isSelected = viewModel.selectedPaymentMethod == method
        let isAvailable = method.isAvailable

        return Button {
            guard isAvailable else { return }
            viewModel.selectedPaymentMethod = method
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isAvailable ? (isSelected ? "checkmark.circle.fill" : "circle") : "circle.dashed")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.textSecondary.opacity(0.35))

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(isAvailable ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.5))

                Text(title)
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(isAvailable ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.5))

                Spacer()

                if !isAvailable {
                    Text(localization.string(.comingSoon))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 2)
                        .background(AppColor.surface)
                        .clipShape(Capsule())
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.sm)
            .background(isSelected ? AppColor.primary.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            .opacity(isAvailable ? 1 : 0.7)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
        .accessibilityIdentifier(method == .card ? "paymentMethodCard" : "paymentMethodCashOnDelivery")
    }

    // MARK: - Summary

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(localization.string(.orderSummarySectionTitle))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text("\(viewModel.items.reduce(0) { $0 + $1.quantity }) \(localization.string(.items))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }

            VStack(spacing: AppSpacing.xs) {
                summaryRow(title: localization.string(.subtotal), value: viewModel.subtotal.formatted)
                summaryRow(
                    title: localization.string(.shippingSectionTitle),
                    value: viewModel.selectedShippingMethod.price.minorUnits > 0
                        ? viewModel.selectedShippingMethod.price.formatted
                        : localization.string(.shippingFree)
                )
                Divider()
                summaryRow(title: localization.string(.total), value: viewModel.total.formatted, emphasized: true)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func summaryRow(title: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasized ? AppTypography.headline : AppTypography.body)
                .foregroundStyle(emphasized ? AppColor.textPrimary : AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(emphasized ? AppTypography.title : AppTypography.bodyEmphasis)
                .foregroundStyle(emphasized ? AppColor.primary : AppColor.textPrimary)
        }
    }

    private var placeOrderButton: some View {
        BaseButton(
            title: localization.string(.placeOrder),
            kind: .primary,
            size: .large,
            isLoading: viewModel.isPlacingOrder
        ) {
            Task {
                let orderNumber = await viewModel.placeOrder()
                onPlaceOrder(orderNumber)
            }
        }
        .accessibilityIdentifier("placeOrderButton")
    }
}

#Preview {
    CheckoutPaymentView(
        viewModel: CheckoutViewModel(
            items: [],
            selectedShippingMethod: .standard,
            addressRepository: MockAddressRepository(),
            cartRepository: MockCartRepository(),
            orderRepository: MockOrderRepository(),
            cartBadgeStore: CartBadgeStore()
        ),
        onBack: {},
        onPlaceOrder: { _ in }
    )
    .environment(LocalizationManager())
}
