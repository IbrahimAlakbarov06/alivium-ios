//
//  ProductFilter.swift
//  alivium
//

/// Domain-side sort criteria for the Category/Product Listing screen. `String` raw values let
/// `LocalizedKey` map each case to its display copy the same way `LocalizedKey.categoryName(forId:)`
/// resolves a mock category's id, without this file importing anything from Core/Localization.
enum ProductSortOption: String, CaseIterable, Hashable {
    case featured
    case priceLowToHigh
    case priceHighToLow
    case topRated
}
