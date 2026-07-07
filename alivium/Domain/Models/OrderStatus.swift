//
//  OrderStatus.swift
//  alivium
//

/// Mirrors the backend's Order status progression (CLAUDE.md 13: Pending → Confirmed →
/// Processing → Shipped → Delivered). `cancelled` is a terminal state reachable from any point
/// rather than a step in that sequence, so it's excluded from `progression` and shown as its own
/// distinct badge/state in the UI instead of a stage in the timeline.
enum OrderStatus: String, CaseIterable, Equatable, Hashable {
    case pending
    case confirmed
    case processing
    case shipped
    case delivered
    case cancelled

    /// The real progression a non-cancelled order moves through — drives Order Detail's status
    /// timeline (current stage highlighted, later stages muted).
    static let progression: [OrderStatus] = [.pending, .confirmed, .processing, .shipped, .delivered]
}
