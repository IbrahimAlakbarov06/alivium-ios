//
//  CartItem.swift
//  alivium
//

struct CartItem: Identifiable, Equatable {
    let id: String
    let product: Product
    let selectedVariant: ProductVariant?
    /// The only field that actually changes in place — a stepper adjustment maps to updating
    /// this on the matching line item rather than replacing the whole cart.
    var quantity: Int
}
