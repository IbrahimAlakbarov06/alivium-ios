//
//  OrderDetailViewModel.swift
//  alivium
//

import Observation

/// Unlike `ProductDetailViewModel`/`CollectionDetailViewModel` (which take their root object and
/// then fetch *additional* data the list screen never had — reviews, a collection's products),
/// an `Order` arrives from Order History already carrying every field Order Detail displays
/// (line items, address, shipping/payment method, status). There's nothing left to fetch, so
/// this holds the order directly rather than re-fetching it through a `ViewState` for its own
/// sake (CLAUDE.md 9.1: "no over-engineering... pragmatic senior code, not ceremony").
@Observable
final class OrderDetailViewModel {
    private(set) var order: Order
    private(set) var isCancelling = false

    private let orderRepository: OrderRepository

    var canCancel: Bool { order.status == .pending }

    init(order: Order, orderRepository: OrderRepository) {
        self.order = order
        self.orderRepository = orderRepository
    }

    /// Only reachable while `order.status == .pending` — the View gates the Cancel action the
    /// same way, but this stays defensive since a confirmation dialog can, in principle, fire
    /// after the underlying state already moved on.
    @discardableResult
    func cancelOrder() async -> Bool {
        guard canCancel, !isCancelling else { return false }
        isCancelling = true
        defer { isCancelling = false }
        do {
            try await orderRepository.updateStatus(orderId: order.id, status: .cancelled)
            order.status = .cancelled
            return true
        } catch {
            return false
        }
    }
}
