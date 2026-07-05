//
//  MockCartRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend Cart
/// endpoints are wired (CLAUDE.md Phase 2). Starts empty — there's no real backend session yet,
/// so a fresh Guest (or any fresh launch) must start with an empty cart rather than a hardcoded
/// seed list; items only appear once something is actually added during the session.
final class MockCartRepository: CartRepository {
    private var items: [CartItem] = []

    func fetchCartItems() async throws -> [CartItem] {
        try await Task.sleep(for: .seconds(0.6))
        return items
    }

    func addItem(product: Product, variant: ProductVariant?, quantity: Int) async throws -> CartItem {
        try await Task.sleep(for: .milliseconds(300))
        if let index = items.firstIndex(where: { $0.product.id == product.id && $0.selectedVariant == variant }) {
            items[index].quantity += quantity
            return items[index]
        }
        let newItem = CartItem(id: UUID().uuidString, product: product, selectedVariant: variant, quantity: quantity)
        items.append(newItem)
        return newItem
    }

    func updateQuantity(itemId: String, quantity: Int) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let index = items.firstIndex(where: { $0.id == itemId }) else { return }
        items[index].quantity = quantity
    }

    func removeItem(itemId: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        items.removeAll { $0.id == itemId }
    }
}
