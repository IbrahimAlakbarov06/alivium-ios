//
//  MockNotificationRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real APIClient-backed implementation once the backend
/// Notification endpoints are wired (CLAUDE.md Phase 2). Timestamps are computed relative to
/// "now" (not fixed dates) so the relative-time formatting in `NotificationsView` always has a
/// realistic spread to render, however long after this file was written the app is actually run.
final class MockNotificationRepository: NotificationRepository {
    private var notifications: [AppNotification] = [
        AppNotification(
            id: "n-1", type: .order,
            title: "Your order has shipped",
            message: "Order #1042 is on its way and should arrive in 3-5 days.",
            timestamp: Date().addingTimeInterval(-2 * 3600), isRead: false
        ),
        AppNotification(
            id: "n-2", type: .promotion,
            title: "20% off new arrivals",
            message: "Enjoy 20% off The Autumn Edit this week only.",
            timestamp: Date().addingTimeInterval(-26 * 3600), isRead: false
        ),
        AppNotification(
            id: "n-3", type: .chat,
            title: "New reply from Support",
            message: "Aysel replied in your Support Chat conversation.",
            timestamp: Date().addingTimeInterval(-3 * 86400), isRead: true
        ),
        AppNotification(
            id: "n-4", type: .wishlist,
            title: "Price drop on a saved item",
            message: "Suede Ankle Boots just dropped to US$175,00.",
            timestamp: Date().addingTimeInterval(-5 * 86400), isRead: true
        ),
        AppNotification(
            id: "n-5", type: .order,
            title: "Order confirmed",
            message: "Your order #1039 has been confirmed and is being prepared.",
            timestamp: Date().addingTimeInterval(-9 * 86400), isRead: true
        ),
        AppNotification(
            id: "n-6", type: .promotion,
            title: "Weekend flash sale",
            message: "Up to 30% off select dresses and outerwear, this weekend only.",
            timestamp: Date().addingTimeInterval(-12 * 86400), isRead: true
        )
    ]

    func fetchNotifications() async throws -> [AppNotification] {
        try await Task.sleep(for: .seconds(0.6))
        return notifications
    }

    func markAsRead(id: String) async throws {
        try await Task.sleep(for: .milliseconds(200))
        guard let index = notifications.firstIndex(where: { $0.id == id }) else { return }
        notifications[index].isRead = true
    }

    func markAllAsRead() async throws {
        try await Task.sleep(for: .milliseconds(200))
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}
