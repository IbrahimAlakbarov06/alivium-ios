//
//  CartRepository.swift
//  alivium
//

protocol CartRepository {
    func fetchCartItems() async throws -> [CartItem]
    func updateQuantity(itemId: String, quantity: Int) async throws
    func removeItem(itemId: String) async throws
}
