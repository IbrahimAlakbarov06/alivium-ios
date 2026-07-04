//
//  WishlistViewState.swift
//  alivium
//

enum WishlistViewState: Equatable {
    case idle
    case loading
    case loaded([Product])
    case empty
    case error(LocalizedKey)
}
