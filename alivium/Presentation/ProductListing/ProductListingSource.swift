//
//  ProductListingSource.swift
//  alivium
//

/// What Category/Product Listing was pushed to show — carried as a value (not resolved title
/// strings) so the screen can be pushed imperatively via `.navigationDestination(item:)` from
/// Home's "Show all" and Search's category taps alike, and re-localize itself like every other
/// screen's `ViewState` does.
enum ProductListingSource: Hashable {
    /// A Discover category tap — the repository fetches by `category.id`.
    case category(Category)
    /// A Home rail's "Show all" — the products are already in memory from the home feed, so
    /// there's no reason to refetch them.
    case curated(titleKey: LocalizedKey, products: [Product])
}
