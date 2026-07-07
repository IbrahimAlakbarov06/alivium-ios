//
//  ProductVariant.swift
//  alivium
//

struct ProductVariant: Identifiable, Equatable, Hashable {
    let id: String
    let size: String
    let color: String
    let stockQuantity: Int

    var isInStock: Bool { stockQuantity > 0 }

    /// Real-world display order for a product's distinct sizes — used by both Product Detail and
    /// Wishlist's inline dropdown (previously each hardcoded its own `["S", "M", "L"]` filter,
    /// which silently produced an empty list for anything sized outside that set, e.g. numeric
    /// shoe sizes). Numeric sizes ("36"..."41") sort ascending; clothing sizes follow the
    /// canonical XS-XXL order; anything else (e.g. "One Size") sorts alphabetically after those.
    static func sortedSizes(in variants: [ProductVariant]) -> [String] {
        let present = Set(variants.map(\.size))
        guard !present.isEmpty else { return [] }
        if present.allSatisfy({ Int($0) != nil }) {
            return present.sorted { Int($0)! < Int($1)! }
        }
        let clothingOrder = ["XS", "S", "M", "L", "XL", "XXL"]
        let known = clothingOrder.filter { present.contains($0) }
        let unknown = present.subtracting(clothingOrder).sorted()
        return known + unknown
    }
}
