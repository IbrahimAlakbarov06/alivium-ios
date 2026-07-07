//
//  NotificationRepository.swift
//  alivium
//

protocol NotificationRepository {
    func fetchNotifications() async throws -> [AppNotification]
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
}
