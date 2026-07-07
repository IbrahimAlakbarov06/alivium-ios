//
//  Category.swift
//  alivium
//

/// Self-referential per the backend's parent/subcategory structure. Home only ever displays
/// top-level categories as chips; the recursive `subcategories` are here for Discover's tree
/// view later, so this model doesn't need to change shape when that screen is built.
struct Category: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let parentId: String?
    let subcategories: [Category]
    /// Product count for this specific category (not a sum of its subcategories') — used by
    /// Discover's subcategory list (e.g. "Dresses (36 Items)").
    let itemCount: Int
}
