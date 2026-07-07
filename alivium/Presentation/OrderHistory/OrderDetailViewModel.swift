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
    let order: Order

    init(order: Order) {
        self.order = order
    }
}
