//
//  NotificationsViewModel.swift
//  alivium
//

import Observation

@Observable
final class NotificationsViewModel {
    private(set) var state: NotificationsViewState = .idle

    private let notificationRepository: NotificationRepository

    /// Read by Home's bell icon for its badge dot — a single shared instance of this ViewModel
    /// (owned by `MainTabView`, like `HomeViewModel` itself) means Home just reads this computed
    /// property directly instead of needing a separate cross-screen badge store the way Cart's
    /// count does (which genuinely has multiple independent mutators: Cart/Wishlist/Product
    /// Detail). Only this ViewModel ever changes read state, so there's nothing to coordinate.
    var unreadCount: Int {
        guard case .loaded(let notifications) = state else { return 0 }
        return notifications.filter { !$0.isRead }.count
    }

    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await load() }
    }

    func load() async {
        state = .loading
        do {
            let notifications = try await notificationRepository.fetchNotifications()
            state = notifications.isEmpty ? .empty : .loaded(notifications)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    /// Updates in place immediately (matching `CartViewModel.updateQuantity`'s reasoning — a tap
    /// should feel instant) and fires the repository call alongside; Phase 1's mock always
    /// succeeds, so there's no rollback path to build yet.
    func markAsRead(_ notification: AppNotification) {
        guard case .loaded(var notifications) = state,
              let index = notifications.firstIndex(where: { $0.id == notification.id }),
              !notifications[index].isRead else { return }
        notifications[index].isRead = true
        state = .loaded(notifications)
        Task { try? await notificationRepository.markAsRead(id: notification.id) }
    }

    func markAllAsRead() {
        guard case .loaded(var notifications) = state else { return }
        for index in notifications.indices { notifications[index].isRead = true }
        state = .loaded(notifications)
        Task { try? await notificationRepository.markAllAsRead() }
    }
}
