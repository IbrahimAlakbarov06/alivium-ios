//
//  OrderRepository.swift
//  alivium
//

protocol OrderRepository {
    /// Newest-first — matches how Order History always wants to show a just-placed order at
    /// the top, without the ViewModel having to re-sort.
    func fetchOrders() async throws -> [Order]
    /// A dedicated single-order fetch (rather than `fetchOrders().first { $0.id == id }` client
    /// side) — matches how a real backend's Order Detail screen would hit its own
    /// `GET /orders/{id}`, so Order Detail's ViewModel has a real seam to swap to `DefaultOrderRepository`
    /// against in Phase 2.
    func fetchOrder(id: String) async throws -> Order?
    /// Called once Checkout's Payment step actually places an order — persists it so Order
    /// History reflects real usage, not just the static seed data.
    func placeOrder(_ order: Order) async throws
}
