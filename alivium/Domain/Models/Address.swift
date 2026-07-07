//
//  Address.swift
//  alivium
//

struct Address: Identifiable, Equatable, Hashable {
    let id: String
    /// Short nickname the shopper gave this address (e.g. "Home", "Office") — distinct from
    /// `fullName`, which is the recipient's name on the delivery itself.
    let label: String
    let fullName: String
    let phone: String
    let addressLine: String
    let city: String
    let postalCode: String
}
