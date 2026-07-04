//
//  CartView.swift
//  alivium
//

import SwiftUI

struct CartView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: CartViewModel

    /// Wired to the tab shell's Home tab — "Start Browsing" from the empty state.
    let onBrowseHome: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)

            content
        }
        .background(AppColor.backgroundOffWhite)
        .task { viewModel.onAppear() }
    }

    private var topBar: some View {
        HStack {
            Text(localization.string(.cartTab))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            EmptyStateView(
                icon: "bag",
                title: localization.string(.cartEmptyTitle),
                subtitle: localization.string(.cartEmptySubtitle),
                actionTitle: localization.string(.startBrowsing),
                action: onBrowseHome
            )
        case .loaded:
            loadedContent
        case .error(let key):
            errorState(key)
        }
    }

    private var loadedContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(viewModel.items) { item in
                    CartLineItemRow(
                        item: item,
                        onQuantityChange: { newQuantity in
                            viewModel.updateQuantity(for: item, to: newQuantity)
                        },
                        onRemove: {
                            Task { await viewModel.remove(item) }
                        }
                    )
                }

                orderSummary
            }
            .padding(AppSpacing.md)
        }
    }

    private var orderSummary: some View {
        VStack(spacing: AppSpacing.md) {
            voucherRow
            shippingPicker

            Divider()

            summaryRow(title: localization.string(.subtotal), value: viewModel.subtotal.formatted)
            summaryRow(title: localization.string(.total), value: viewModel.total.formatted, emphasized: true)

            BaseButton(title: localization.string(.proceedToCheckout), kind: .primary, size: .large) {
                // TODO: navigate to Checkout once it exists.
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private var voucherRow: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack(spacing: AppSpacing.sm) {
                BaseTextField(
                    placeholder: localization.string(.voucherCodePlaceholder),
                    text: $viewModel.voucherCode
                )

                BaseButton(title: localization.string(.apply), kind: .secondary, size: .medium) {
                    viewModel.applyVoucher()
                }
            }

            if viewModel.isVoucherApplied {
                Text(localization.string(.voucherApplied))
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.accent)
            }
        }
    }

    private var shippingPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(localization.string(.shippingSectionTitle))
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)

            HStack(spacing: AppSpacing.xs) {
                ForEach(ShippingMethod.allCases) { method in
                    CategoryChip(
                        title: shippingLabel(for: method),
                        isSelected: viewModel.selectedShippingMethod == method
                    ) {
                        viewModel.selectedShippingMethod = method
                    }
                }
            }
        }
    }

    private func shippingLabel(for method: ShippingMethod) -> String {
        let name: String
        switch method {
        case .free: name = localization.string(.shippingFree)
        case .standard: name = localization.string(.shippingStandard)
        case .fast: name = localization.string(.shippingFast)
        }
        return method.price.minorUnits == 0 ? name : "\(name) \(method.price.formatted)"
    }

    private func summaryRow(title: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasized ? AppTypography.headline : AppTypography.body)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
            Text(value)
                .font(emphasized ? AppTypography.headline : AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadCart() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview {
    CartView(
        viewModel: CartViewModel(cartRepository: MockCartRepository()),
        onBrowseHome: {}
    )
    .environment(LocalizationManager())
}
