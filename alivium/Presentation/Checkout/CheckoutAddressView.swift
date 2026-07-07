//
//  CheckoutAddressView.swift
//  alivium
//

import SwiftUI

/// Step 1 of Checkout. Presented at the root of `CheckoutFlowView`'s cover, so "cancel" here
/// means leaving the whole flow (an `xmark`, not a back chevron) — matching how a modal's first
/// screen conventionally offers a close button rather than implying there's somewhere to go back
/// to within the flow itself.
struct CheckoutAddressView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: CheckoutViewModel
    @State private var isShowingAddAddressForm = false
    let onCancel: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .background(AppColor.backgroundOffWhite)
        .task { viewModel.onAppearAddressStep() }
        .sheet(isPresented: $isShowingAddAddressForm) {
            AddAddressView(
                addressRepository: viewModel.addressRepository,
                onSave: { address in
                    isShowingAddAddressForm = false
                    Task {
                        await viewModel.loadAddresses()
                        viewModel.selectedAddressId = address.id
                    }
                },
                onCancel: { isShowingAddAddressForm = false }
            )
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }
                .accessibilityIdentifier("checkoutCancelButton")
                Spacer()
            }

            Text(localization.string(.checkoutAddressTitle))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.sm)
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.addressState {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded:
            loadedContent
        case .error(let key):
            errorState(key)
        }
    }

    private var loadedContent: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.addresses) { address in
                        addressRow(address)
                    }
                    addNewAddressButton
                }
                .padding(AppSpacing.md)
            }

            BaseButton(
                title: localization.string(.continueLabel),
                kind: .primary,
                size: .large,
                isEnabled: viewModel.canContinueFromAddress
            ) {
                onContinue()
            }
            .accessibilityIdentifier("checkoutContinueButton")
            .padding(AppSpacing.md)
        }
    }

    private func addressRow(_ address: Address) -> some View {
        let isSelected = viewModel.selectedAddressId == address.id

        return Button {
            viewModel.selectedAddressId = address.id
        } label: {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.textSecondary.opacity(0.35))
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(address.label)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(address.fullName)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(address.addressLine), \(address.city)")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Text(address.phone)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.sm)
            .background(isSelected ? AppColor.primary.opacity(0.06) : AppColor.background)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("checkoutAddressRow-\(address.id)")
    }

    private var addNewAddressButton: some View {
        Button {
            isShowingAddAddressForm = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.primary)
                Text(localization.string(.addNewAddress))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.primary)
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("addNewAddressButton")
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadAddresses() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview {
    CheckoutAddressView(
        viewModel: CheckoutViewModel(
            items: [],
            selectedShippingMethod: .standard,
            addressRepository: MockAddressRepository(),
            cartRepository: MockCartRepository(),
            orderRepository: MockOrderRepository(),
            cartBadgeStore: CartBadgeStore()
        ),
        onCancel: {},
        onContinue: {}
    )
    .environment(LocalizationManager())
}
