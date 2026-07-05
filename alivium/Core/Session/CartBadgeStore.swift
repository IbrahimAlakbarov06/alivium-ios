//
//  CartBadgeStore.swift
//  alivium
//

import Observation

/// Single source of truth for the Cart tab's badge count. Owned by `AppContainer` (mirrors
/// `UserSession`'s shape) and shared by every ViewModel that can add/remove cart items —
/// `CartViewModel` itself, but also `ProductDetailViewModel`/`WishlistViewModel`, which mutate
/// the same `CartRepository` instance from a different screen. Without this, the tab bar badge
/// only reflected whatever `CartViewModel.items` happened to hold, which was stale until the
/// Cart tab itself was opened.
@Observable
final class CartBadgeStore {
    private(set) var itemCount = 0

    func set(_ count: Int) {
        itemCount = count
    }

    func increment(by delta: Int) {
        itemCount = max(0, itemCount + delta)
    }
}
