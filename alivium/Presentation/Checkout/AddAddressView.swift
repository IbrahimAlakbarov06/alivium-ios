//
//  AddAddressView.swift
//  alivium
//

import SwiftUI

/// Standalone add/edit form — owns its own local field state and talks to `AddressRepository`
/// directly rather than binding through a screen-specific ViewModel (like `CheckoutViewModel`).
/// This is what makes it reusable as-is from both Checkout's Address step and Profile's
/// Addresses screen, matching CLAUDE.md 9.6's "one component, not copy-pasted variants."
struct AddAddressView: View {
    @Environment(LocalizationManager.self) private var localization
    let addressRepository: AddressRepository
    /// Non-nil when editing a saved address in place rather than adding a new one — pre-fills
    /// every field and calls `updateAddress` instead of `addAddress` on save.
    let existingAddress: Address?
    let onSave: (Address) -> Void
    let onCancel: () -> Void

    @State private var label: String
    @State private var fullName: String
    /// Local digits only — the "+994" country code is a fixed prefix shown by `BaseTextField`,
    /// never part of what's typed or stored here.
    @State private var phone: String
    @State private var addressLine: String
    @State private var city: String
    @State private var postalCode: String
    @State private var isSaving = false

    init(
        addressRepository: AddressRepository,
        existingAddress: Address? = nil,
        onSave: @escaping (Address) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.addressRepository = addressRepository
        self.existingAddress = existingAddress
        self.onSave = onSave
        self.onCancel = onCancel
        _label = State(initialValue: existingAddress?.label ?? "")
        _fullName = State(initialValue: existingAddress?.fullName ?? "")
        _phone = State(initialValue: Self.localDigits(from: existingAddress?.phone))
        _addressLine = State(initialValue: existingAddress?.addressLine ?? "")
        _city = State(initialValue: existingAddress?.city ?? "")
        _postalCode = State(initialValue: existingAddress?.postalCode ?? "")
    }

    private var canSave: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty
            && !phone.trimmingCharacters(in: .whitespaces).isEmpty
            && !addressLine.trimmingCharacters(in: .whitespaces).isEmpty
            && !city.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.md) {
                    BaseTextField(placeholder: localization.string(.addressLabelPlaceholder), text: $label)
                    BaseTextField(placeholder: localization.string(.fullName), text: $fullName)
                    BaseTextField(
                        placeholder: localization.string(.phoneNumberPlaceholder),
                        text: $phone,
                        keyboardType: .phonePad,
                        prefix: "+994"
                    )
                    BaseTextField(placeholder: localization.string(.addressLinePlaceholder), text: $addressLine)

                    HStack(spacing: AppSpacing.sm) {
                        BaseTextField(placeholder: localization.string(.cityPlaceholder), text: $city)
                        BaseTextField(placeholder: localization.string(.postalCodePlaceholder), text: $postalCode)
                    }

                    BaseButton(
                        title: localization.string(.saveAddress),
                        kind: .primary,
                        size: .large,
                        isLoading: isSaving,
                        isEnabled: canSave
                    ) {
                        Task { await save() }
                    }
                    .accessibilityIdentifier("saveAddressButton")
                    .padding(.top, AppSpacing.sm)
                }
                .padding(AppSpacing.md)
            }
            .background(AppColor.backgroundOffWhite)
            .navigationTitle(existingAddress == nil ? localization.string(.addNewAddress) : localization.string(.editAddressTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localization.string(.cancel), action: onCancel)
                }
            }
        }
    }

    private func save() async {
        guard canSave, !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        let address = Address(
            id: existingAddress?.id ?? UUID().uuidString,
            label: label.trimmingCharacters(in: .whitespaces).isEmpty ? "Address" : label,
            fullName: fullName,
            phone: "+994 \(phone.trimmingCharacters(in: .whitespaces))",
            addressLine: addressLine,
            city: city,
            postalCode: postalCode
        )
        do {
            if existingAddress != nil {
                try await addressRepository.updateAddress(address)
            } else {
                try await addressRepository.addAddress(address)
            }
            onSave(address)
        } catch {
            // Phase 1 mock never actually throws here.
        }
    }

    /// Strips a leading "+994" (with or without the space `MockAddressRepository`'s seed data
    /// uses) so editing a saved address re-populates the field with only the local digits the
    /// fixed prefix doesn't already show.
    private static func localDigits(from fullPhone: String?) -> String {
        guard let fullPhone else { return "" }
        return fullPhone.replacingOccurrences(of: "+994", with: "").trimmingCharacters(in: .whitespaces)
    }
}

#Preview("Add") {
    AddAddressView(
        addressRepository: MockAddressRepository(),
        onSave: { _ in },
        onCancel: {}
    )
    .environment(LocalizationManager())
}

#Preview("Edit") {
    AddAddressView(
        addressRepository: MockAddressRepository(),
        existingAddress: Address(
            id: "addr-1", label: "Home", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
            addressLine: "28 May küç. 15, mənzil 42", city: "Bakı", postalCode: "AZ1000"
        ),
        onSave: { _ in },
        onCancel: {}
    )
    .environment(LocalizationManager())
}
