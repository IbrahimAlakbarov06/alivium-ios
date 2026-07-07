//
//  Order.swift
//  alivium
//

import Foundation

/// A placed order — created once Checkout's Payment step actually places one (see
/// `CheckoutViewModel.placeOrder()`), and read back by Order History/Order Detail. Reuses
/// `CartItem` for line items rather than a parallel `OrderItem` model, since the shape (product,
/// variant, quantity) is identical and nothing about a placed order's items differs structurally
/// from a cart's.
struct Order: Identifiable, Equatable, Hashable {
    let id: String
    let orderNumber: String
    let items: [CartItem]
    let address: Address
    let shippingMethod: ShippingMethod
    let paymentMethod: PaymentMethod
    var status: OrderStatus
    let subtotal: Money
    let placedAt: Date

    var shippingCost: Money { shippingMethod.price }
    var total: Money { Money(minorUnits: subtotal.minorUnits + shippingCost.minorUnits) }
    /// Sum of quantities, not line-item count — matches Cart/Checkout's own `itemCount`.
    var itemCount: Int { items.reduce(0) { $0 + $1.quantity } }
}
