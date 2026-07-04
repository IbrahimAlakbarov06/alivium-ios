//
//  ProductVariant.swift
//  alivium
//

struct ProductVariant: Identifiable, Equatable {
    let id: String
    let size: String
    let color: String
    let stockQuantity: Int

    var isInStock: Bool { stockQuantity > 0 }
}
