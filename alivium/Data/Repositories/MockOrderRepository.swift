//
//  MockOrderRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend's
/// `OrderController` is wired (CLAUDE.md Phase 2). Seeded with three past orders spanning every
/// non-cancelled status, built from `MockProductRepository`'s real product data rather than
/// inventing unrelated sample items — and keeps newly placed orders in memory so Order History
/// reflects real usage for the rest of the session, not just the static seed.
final class MockOrderRepository: OrderRepository {
    private var orders: [Order]

    init() {
        let products = MockProductRepository.featuredProducts
        let calendar = Calendar.current
        let now = Date()

        func variant(of product: Product, color: String, size: String) -> ProductVariant? {
            product.variants.first { $0.color == color && $0.size == size } ?? product.variants.first
        }

        func subtotal(of items: [CartItem]) -> Money {
            Money(minorUnits: items.reduce(0) { $0 + $1.product.effectivePrice.minorUnits * $1.quantity })
        }

        let homeAddress = Address(
            id: "addr-1", label: "Home", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
            addressLine: "28 May küç. 15, mənzil 42", city: "Bakı", postalCode: "AZ1000"
        )
        let officeAddress = Address(
            id: "addr-2", label: "Office", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
            addressLine: "Nizami küç. 203, ofis 8", city: "Bakı", postalCode: "AZ1010"
        )

        let dress = products[0]   // Silk Wrap Midi Dress
        let coat = products[1]    // Tailored Wool Coat
        let sweater = products[2] // Cashmere Blend Sweater
        let skirt = products[3]   // Pleated Satin Skirt

        let deliveredItems = [
            CartItem(id: "oi-1", product: dress, selectedVariant: variant(of: dress, color: "Ivory", size: "M"), quantity: 1),
            CartItem(id: "oi-2", product: skirt, selectedVariant: variant(of: skirt, color: "Champagne", size: "M"), quantity: 1)
        ]
        let shippedItems = [
            CartItem(id: "oi-3", product: coat, selectedVariant: variant(of: coat, color: "Camel", size: "M"), quantity: 1)
        ]
        let pendingItems = [
            CartItem(id: "oi-4", product: sweater, selectedVariant: variant(of: sweater, color: "Black", size: "M"), quantity: 2)
        ]

        self.orders = [
            Order(
                id: "order-1", orderNumber: "AL-58213", items: deliveredItems, address: homeAddress,
                shippingMethod: .standard, paymentMethod: .cashOnDelivery, status: .delivered,
                subtotal: subtotal(of: deliveredItems),
                placedAt: calendar.date(byAdding: .day, value: -14, to: now) ?? now
            ),
            Order(
                id: "order-2", orderNumber: "AL-61947", items: shippedItems, address: officeAddress,
                shippingMethod: .fast, paymentMethod: .cashOnDelivery, status: .shipped,
                subtotal: subtotal(of: shippedItems),
                placedAt: calendar.date(byAdding: .day, value: -5, to: now) ?? now
            ),
            Order(
                id: "order-3", orderNumber: "AL-70532", items: pendingItems, address: homeAddress,
                shippingMethod: .free, paymentMethod: .cashOnDelivery, status: .pending,
                subtotal: subtotal(of: pendingItems),
                placedAt: calendar.date(byAdding: .day, value: -1, to: now) ?? now
            )
        ]
    }

    func fetchOrders() async throws -> [Order] {
        try await Task.sleep(for: .seconds(0.6))
        return orders.sorted { $0.placedAt > $1.placedAt }
    }

    func fetchOrder(id: String) async throws -> Order? {
        try await Task.sleep(for: .milliseconds(400))
        return orders.first { $0.id == id }
    }

    func placeOrder(_ order: Order) async throws {
        try await Task.sleep(for: .milliseconds(300))
        orders.append(order)
    }

    func updateStatus(orderId: String, status: OrderStatus) async throws {
        try await Task.sleep(for: .milliseconds(300))
        guard let index = orders.firstIndex(where: { $0.id == orderId }) else { return }
        orders[index].status = status
    }
}
