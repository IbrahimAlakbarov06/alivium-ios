//
//  ProductListingViewState.swift
//  alivium
//

/// Reflects the unfiltered fetch only — toggling the on-sale filter down to zero results is
/// handled inline within `.loaded` (matching Discover's `emptyResultsState` for a filtered-empty
/// search), not by flipping back to `.empty`, which is reserved for "this category truly has no
/// products."
enum ProductListingViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty
    case error(LocalizedKey)
}
