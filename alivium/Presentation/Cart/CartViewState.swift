//
//  CartViewState.swift
//  alivium
//

/// Line items themselves live in `CartViewModel.items` (mutated in place for quantity changes),
/// so `.loaded` carries no associated value — this only tracks the load lifecycle.
enum CartViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(LocalizedKey)
}
