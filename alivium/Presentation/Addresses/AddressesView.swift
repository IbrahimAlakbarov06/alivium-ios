//
//  AddressesView.swift
//  alivium
//

import SwiftUI

/// Reached from Profile's "Addresses" row. Shows the same saved addresses Checkout's Address
/// step reads from (both point at the same `AddressRepository` instance from `AppContainer`),
/// with add/edit/delete — Checkout only ever needed to pick one, this is where they're actually
/// managed.
struct AddressesView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: AddressesViewModel
    @State private var isShowingAddAddressForm = false
    @State private var addressBeingEdited: Address?
    @State private var addressPendingDelete: Address?

    var body: some View {
        content
            .background(AppColor.backgroundOffWhite)
            .navigationTitle(localization.string(.addresses))
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.onAppear() }
            .sheet(isPresented: $isShowingAddAddressForm) {
                AddAddressView(
                    addressRepository: viewModel.addressRepository,
                    onSave: { _ in
                        isShowingAddAddressForm = false
                        Task { await viewModel.loadAddresses() }
                    },
                    onCancel: { isShowingAddAddressForm = false }
                )
            }
            .sheet(item: $addressBeingEdited) { address in
                AddAddressView(
                    addressRepository: viewModel.addressRepository,
                    existingAddress: address,
                    onSave: { _ in
                        addressBeingEdited = nil
                        Task { await viewModel.loadAddresses() }
                    },
                    onCancel: { addressBeingEdited = nil }
                )
            }
            .confirmationDialog(
                localization.string(.deleteAddressConfirmTitle),
                isPresented: Binding(
                    get: { addressPendingDelete != nil },
                    set: { isPresented in if !isPresented { addressPendingDelete = nil } }
                ),
                titleVisibility: .visible
            ) {
                Button(localization.string(.deleteAddress), role: .destructive) {
                    if let addressPendingDelete {
                        Task { await viewModel.delete(addressPendingDelete) }
                    }
                }
                Button(localization.string(.cancel), role: .cancel) {}
            } message: {
                Text(localization.string(.deleteAddressConfirmMessage))
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let addresses):
            list(addresses)
        case .empty:
            EmptyStateView(
                icon: "mappin.and.ellipse",
                title: localization.string(.addressesEmptyTitle),
                subtitle: localization.string(.addressesEmptySubtitle),
                actionTitle: localization.string(.addNewAddress),
                action: { isShowingAddAddressForm = true }
            )
        case .error(let key):
            errorState(key)
        }
    }

    private func list(_ addresses: [Address]) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(addresses) { address in
                    addressRow(address)
                }
                addNewAddressButton
            }
            .padding(AppSpacing.md)
        }
        .accessibilityIdentifier("addressesScrollView")
    }

    private func addressRow(_ address: Address) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
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

            Spacer(minLength: AppSpacing.sm)

            VStack(spacing: AppSpacing.md) {
                Button {
                    addressBeingEdited = address
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textSecondary.opacity(0.55))
                }
                .accessibilityLabel(localization.string(.editAddress))
                // Overrides the row's own identifier (which would otherwise propagate down to
                // every child, making this indistinguishable from the row's other controls).
                .accessibilityIdentifier("editAddressButton-\(address.id)")

                Button {
                    addressPendingDelete = address
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.textSecondary.opacity(0.55))
                }
                .accessibilityIdentifier("deleteAddressButton-\(address.id)")
                .accessibilityLabel(localization.string(.deleteAddress))
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
        // No row-level `.accessibilityIdentifier` here — SwiftUI was observed propagating a
        // container's identifier down onto every child element (including the Edit/Delete
        // buttons' own explicit identifiers below), making them indistinguishable from each other.
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
    NavigationStack {
        AddressesView(viewModel: AddressesViewModel(addressRepository: MockAddressRepository()))
    }
    .environment(LocalizationManager())
}
