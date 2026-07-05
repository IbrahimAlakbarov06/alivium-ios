//
//  ProductDetailViewState.swift
//  alivium
//

/// Tracks only the secondary data load (reviews + related products) — the product itself and
/// variant selection are available immediately since the product is passed in directly rather
/// than fetched.
enum ProductDetailViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(LocalizedKey)
}
