//
//  MockAddressRepository.swift
//  alivium
//

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Address endpoints are wired (CLAUDE.md Phase 2).
final class MockAddressRepository: AddressRepository {
    private var addresses: [Address] = [
        Address(
            id: "addr-1", label: "Home", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
            addressLine: "28 May küç. 15, mənzil 42", city: "Bakı", postalCode: "AZ1000"
        ),
        Address(
            id: "addr-2", label: "Office", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
            addressLine: "Nizami küç. 203, ofis 8", city: "Bakı", postalCode: "AZ1010"
        )
    ]

    func fetchAddresses() async throws -> [Address] {
        try await Task.sleep(for: .seconds(0.6))
        return addresses
    }

    func addAddress(_ address: Address) async throws {
        try await Task.sleep(for: .milliseconds(300))
        addresses.append(address)
    }
}
