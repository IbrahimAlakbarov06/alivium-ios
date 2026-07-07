//
//  AddressRepository.swift
//  alivium
//

protocol AddressRepository {
    func fetchAddresses() async throws -> [Address]
    func addAddress(_ address: Address) async throws
}
