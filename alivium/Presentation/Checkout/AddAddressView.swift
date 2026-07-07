//
//  AddAddressView.swift
//  alivium
//

import SwiftUI

/// Presented as a sheet from `CheckoutAddressView`. Binds directly to `CheckoutViewModel`'s
/// `newAddressXxx` fields rather than owning a separate form model — matching how Login/Register
/// bind straight to their ViewModel's plain properties.
struct AddAddressView: View {
    @Environment(LocalizationManager.self) private var localization
    @Bindable var viewModel: CheckoutViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    BaseTextField(placeholder: localization.string(.addressLabelPlaceholder), text: $viewModel.newAddressLabel)
                    BaseTextField(placeholder: localization.string(.fullName), text: $viewModel.newAddressFullName)
                    BaseTextField(
                        placeholder: localization.string(.phoneNumberPlaceholder),
                        text: $viewModel.newAddressPhone,
                        keyboardType: .phonePad
                    )
                    BaseTextField(placeholder: localization.string(.addressLinePlaceholder), text: $viewModel.newAddressLine)

                    HStack(spacing: AppSpacing.sm) {
                        BaseTextField(placeholder: localization.string(.cityPlaceholder), text: $viewModel.newAddressCity)
                        BaseTextField(placeholder: localization.string(.postalCodePlaceholder), text: $viewModel.newAddressPostalCode)
                    }

                    BaseButton(
                        title: localization.string(.saveAddress),
                        kind: .primary,
                        size: .large,
                        isEnabled: viewModel.canSaveNewAddress
                    ) {
                        Task { await viewModel.saveNewAddress() }
                    }
                    .accessibilityIdentifier("saveAddressButton")
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.backgroundOffWhite)
            .navigationTitle(localization.string(.addNewAddress))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.cancel)) {
                        viewModel.isShowingAddAddressForm = false
                    }
                }
            }
        }
    }
}

#Preview {
    AddAddressView(
        viewModel: CheckoutViewModel(
            items: [],
            selectedShippingMethod: .standard,
            addressRepository: MockAddressRepository(),
            cartRepository: MockCartRepository(),
            orderRepository: MockOrderRepository(),
            cartBadgeStore: CartBadgeStore()
        )
    )
    .environment(LocalizationManager())
}
