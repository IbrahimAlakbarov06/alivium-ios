//
//  CheckoutViewModel.swift
//  alivium
//

import Foundation
import Observation

/// One shared ViewModel across all three Checkout steps (Address -> Payment -> Confirmation),
/// matching the task's own architecture note — carrying state across fragmented per-screen
/// ViewModels would lose the selected address/shipping/payment method crossing steps.
/// `items`/`selectedShippingMethod` are a snapshot taken when "Proceed to Checkout" is tapped in
/// Cart, not a live reference back to `CartViewModel` — Cart's own state is free to keep changing
/// (or get cleared, once the order places) independently of whatever this flow is doing.
@Observable
final class CheckoutViewModel: Identifiable {
    let id = UUID()
    let items: [CartItem]
    var selectedShippingMethod: ShippingMethod

    private(set) var addressState: CheckoutAddressState = .idle
    var selectedAddressId: String?

    var selectedPaymentMethod: PaymentMethod = .cashOnDelivery
    private(set) var isPlacingOrder = false

    /// Not `private` — `CheckoutAddressView` hands this straight to `AddAddressView`, which talks
    /// to the repository directly rather than through this ViewModel (see `AddAddressView`'s own
    /// doc comment for why it's a standalone, reusable form).
    let addressRepository: AddressRepository
    private let cartRepository: CartRepository
    private let orderRepository: OrderRepository
    private let cartBadgeStore: CartBadgeStore

    var addresses: [Address] {
        if case .loaded(let addresses) = addressState { return addresses }
        return []
    }

    private var selectedAddress: Address? {
        addresses.first { $0.id == selectedAddressId }
    }

    var canContinueFromAddress: Bool { selectedAddressId != nil }

    var subtotal: Money {
        let minorUnits = items.reduce(0) { $0 + $1.product.effectivePrice.minorUnits * $1.quantity }
        return Money(minorUnits: minorUnits)
    }

    var total: Money {
        Money(minorUnits: subtotal.minorUnits + selectedShippingMethod.price.minorUnits)
    }

    init(
        items: [CartItem],
        selectedShippingMethod: ShippingMethod,
        addressRepository: AddressRepository,
        cartRepository: CartRepository,
        orderRepository: OrderRepository,
        cartBadgeStore: CartBadgeStore
    ) {
        self.items = items
        self.selectedShippingMethod = selectedShippingMethod
        self.addressRepository = addressRepository
        self.cartRepository = cartRepository
        self.orderRepository = orderRepository
        self.cartBadgeStore = cartBadgeStore
    }

    func onAppearAddressStep() {
        guard addressState == .idle else { return }
        Task { await loadAddresses() }
    }

    func loadAddresses() async {
        addressState = .loading
        do {
            let addresses = try await addressRepository.fetchAddresses()
            addressState = .loaded(addresses)
            // Default to the first saved address rather than forcing an empty selection the
            // shopper has to make every time — they can still change it.
            if selectedAddressId == nil {
                selectedAddressId = addresses.first?.id
            }
        } catch {
            addressState = .error(.somethingWentWrong)
        }
    }

    /// Places the order — persists a real `Order` record (so Order History reflects what was
    /// just purchased, not just static seed data) and clears the cart (a real completed purchase
    /// empties it) — returns the generated order number for Confirmation to display.
    @discardableResult
    func placeOrder() async -> String {
        isPlacingOrder = true
        defer { isPlacingOrder = false }
        let orderNumber = "AL-\(Int.random(in: 10_000...99_999))"
        // `canContinueFromAddress` already gates the Address step, so by the time Payment can
        // call this, an address is guaranteed selected — but this stays defensive rather than
        // force-unwrapping, since a placed order with no address would be a silent data bug.
        if let selectedAddress {
            let order = Order(
                id: UUID().uuidString,
                orderNumber: orderNumber,
                items: items,
                address: selectedAddress,
                shippingMethod: selectedShippingMethod,
                paymentMethod: selectedPaymentMethod,
                status: .pending,
                subtotal: subtotal,
                placedAt: Date()
            )
            try? await orderRepository.placeOrder(order)
        }
        try? await cartRepository.clearCart()
        cartBadgeStore.set(0)
        return orderNumber
    }
}
