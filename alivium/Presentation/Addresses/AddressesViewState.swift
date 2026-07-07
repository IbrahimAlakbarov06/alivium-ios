//
//  AddressesViewState.swift
//  alivium
//

enum AddressesViewState: Equatable {
    case idle
    case loading
    case loaded([Address])
    case empty
    case error(LocalizedKey)
}
