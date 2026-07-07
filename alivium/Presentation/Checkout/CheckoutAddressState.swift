//
//  CheckoutAddressState.swift
//  alivium
//

enum CheckoutAddressState: Equatable {
    case idle
    case loading
    case loaded([Address])
    case error(LocalizedKey)
}
