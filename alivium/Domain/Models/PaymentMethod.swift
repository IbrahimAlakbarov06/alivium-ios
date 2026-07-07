//
//  PaymentMethod.swift
//  alivium
//

/// Mirrors the backend's (currently sparse) `PaymentMethod` enum — only `CASH` exists there so
/// far (CLAUDE.md backend status), so `.card` is modeled here for UI honesty (shown, not hidden)
/// but stays permanently unselectable until the backend actually supports it.
enum PaymentMethod: String, CaseIterable, Identifiable, Equatable, Hashable {
    case cashOnDelivery
    case card

    var id: String { rawValue }

    var isAvailable: Bool { self == .cashOnDelivery }
}
