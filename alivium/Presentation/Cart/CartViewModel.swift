//
//  CartViewModel.swift
//  alivium
//

import Foundation
import Observation

@Observable
final class CartViewModel {
    private(set) var state: CartViewState = .idle
    private(set) var items: [CartItem] = []
    var selectedShippingMethod: ShippingMethod = .free
    var voucherCode: String = ""
    private(set) var isVoucherApplied = false

    private let cartRepository: CartRepository
    private let cartBadgeStore: CartBadgeStore

    /// Sum of quantities, not line-item count — what the tab bar badge should show.
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Money {
        let minorUnits = items.reduce(0) { $0 + $1.product.effectivePrice.minorUnits * $1.quantity }
        return Money(minorUnits: minorUnits)
    }

    var total: Money {
        Money(minorUnits: subtotal.minorUnits + selectedShippingMethod.price.minorUnits)
    }

    init(cartRepository: CartRepository, cartBadgeStore: CartBadgeStore) {
        self.cartRepository = cartRepository
        self.cartBadgeStore = cartBadgeStore
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await loadCart() }
    }

    func loadCart() async {
        state = .loading
        do {
            items = try await cartRepository.fetchCartItems()
            state = items.isEmpty ? .empty : .loaded
            // Reconciles the shared badge with the authoritative repository fetch — corrects
            // any drift from screens that add items without ever opening this ViewModel.
            cartBadgeStore.set(itemCount)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    /// Updates in place immediately (a stepper tap should feel instant) and fires the
    /// repository call alongside — Phase 1's mock always succeeds, so there's no rollback path
    /// to build yet.
    func updateQuantity(for item: CartItem, to quantity: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let delta = quantity - items[index].quantity
        items[index].quantity = quantity
        cartBadgeStore.increment(by: delta)
        Task { try? await cartRepository.updateQuantity(itemId: item.id, quantity: quantity) }
    }

    @discardableResult
    func remove(_ item: CartItem) async -> Bool {
        do {
            try await cartRepository.removeItem(itemId: item.id)
            items.removeAll { $0.id == item.id }
            cartBadgeStore.increment(by: -item.quantity)
            if items.isEmpty { state = .empty }
            return true
        } catch {
            return false
        }
    }

    /// Stub — Phase 1 has no real voucher backend, so any non-empty code "applies" successfully.
    func applyVoucher() {
        guard !voucherCode.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isVoucherApplied = true
    }
}
