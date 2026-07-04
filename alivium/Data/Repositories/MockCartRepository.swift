//
//  MockCartRepository.swift
//  alivium
//

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend Cart
/// endpoints are wired (CLAUDE.md Phase 2). Seeded from `MockProductRepository`'s real product
/// data; quantity/removal mutations are kept in memory so the screen behaves believably across
/// a session without a backend.
final class MockCartRepository: CartRepository {
    private lazy var items: [CartItem] = [
        CartItem(
            id: "cart-1",
            product: MockProductRepository.featuredProducts[0],
            selectedVariant: MockProductRepository.featuredProducts[0].variants.first,
            quantity: 1
        ),
        CartItem(
            id: "cart-2",
            product: MockProductRepository.featuredProducts[1],
            selectedVariant: MockProductRepository.featuredProducts[1].variants.first,
            quantity: 2
        ),
        CartItem(
            id: "cart-3",
            product: MockProductRepository.recommendedProducts[2],
            selectedVariant: nil,
            quantity: 1
        )
    ]

    func fetchCartItems() async throws -> [CartItem] {
        try await Task.sleep(for: .seconds(0.6))
        return items
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
