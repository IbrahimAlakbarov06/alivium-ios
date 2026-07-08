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
    /// Product ids the shopper has already submitted a review for — checked against
    /// `ReviewRepository`, not `Order` itself, since a placed order has no notion of its own
    /// review state. Rechecked every time this screen reappears (see `OrderDetailView`'s
    /// `.onAppear`) so returning from Rate Product picks up a just-submitted review.
    private(set) var ratedProductIds: Set<String> = []

    private let orderRepository: OrderRepository
    private let reviewRepository: ReviewRepository

    var canCancel: Bool { order.status == .pending }

    init(order: Order, orderRepository: OrderRepository, reviewRepository: ReviewRepository) {
        self.order = order
        self.orderRepository = orderRepository
        self.reviewRepository = reviewRepository
    }

    /// Only meaningful for a Delivered order — cheap and idempotent, so it's safe to call again
    /// every time the screen reappears rather than gating it behind an idle-style check.
    func loadRatedProducts() async {
        guard order.status == .delivered else { return }
        for item in order.items {
            if let hasReviewed = try? await reviewRepository.hasSubmittedReview(productId: item.product.id), hasReviewed {
                ratedProductIds.insert(item.product.id)
            }
        }
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
