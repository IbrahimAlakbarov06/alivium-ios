//
//  OrderHistoryViewState.swift
//  alivium
//

enum OrderHistoryViewState: Equatable {
    case idle
    case loading
    case loaded([Order])
    case empty
    case error(LocalizedKey)
}
