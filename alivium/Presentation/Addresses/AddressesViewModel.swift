//
//  AddressesViewModel.swift
//  alivium
//

import Observation

/// Reads/writes the SAME `AddressRepository` Checkout's Address step uses — one shared list of
/// saved addresses, not a disconnected copy, so an address added here shows up in Checkout and
/// vice versa.
@Observable
final class AddressesViewModel {
    private(set) var state: AddressesViewState = .idle

    /// Not `private` — handed straight to `AddAddressView` the same way `CheckoutViewModel`
    /// exposes its own `addressRepository`.
    let addressRepository: AddressRepository

    init(addressRepository: AddressRepository) {
        self.addressRepository = addressRepository
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await loadAddresses() }
    }

    func loadAddresses() async {
        state = .loading
        do {
            let addresses = try await addressRepository.fetchAddresses()
            state = addresses.isEmpty ? .empty : .loaded(addresses)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    @discardableResult
    func delete(_ address: Address) async -> Bool {
        do {
            try await addressRepository.deleteAddress(id: address.id)
            await loadAddresses()
            return true
        } catch {
            return false
        }
    }
}
