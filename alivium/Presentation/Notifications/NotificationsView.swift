//
//  NotificationsView.swift
//  alivium
//

import SwiftUI

/// Reached from Home's bell icon. The backend already has a full Notification model/endpoints
/// (CLAUDE.md backend status), so this is built as a real screen — a proper `ViewState`,
/// read/unread tracking, and a repository seam ready for Phase 2 — rather than a throwaway stub.
struct NotificationsView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: NotificationsViewModel

    var body: some View {
        content
            .background(AppColor.backgroundOffWhite)
            .navigationTitle(localization.string(.notifications))
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.onAppear() }
            .toolbar {
                if viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(localization.string(.markAllAsRead)) {
                            viewModel.markAllAsRead()
                        }
                        .font(AppTypography.caption)
                    }
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .loaded(let notifications):
            list(notifications)
        case .empty:
            EmptyStateView(
                icon: "bell",
                title: localization.string(.notificationsEmptyTitle),
                subtitle: localization.string(.notificationsEmptySubtitle)
            )
        case .error(let key):
            errorState(key)
        }
    }

    private func list(_ notifications: [AppNotification]) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.sm) {
                ForEach(notifications) { notification in
                    Button {
                        viewModel.markAsRead(notification)
                    } label: {
                        NotificationRow(notification: notification, relativeTime: relativeTimeString(for: notification.timestamp))
                    }
                    .buttonStyle(.plain)
                }
            }
            // Watches read state (not just count) so a tapped row's unread dot/tint fades out
            // instead of snapping instantly — matches Wishlist's identical removal animation.
            .animation(.easeOut(duration: 0.2), value: notifications.map(\.isRead))
            .padding(AppSpacing.md)
        }
    }

    /// "2 hours ago" / "Yesterday" style — simple elapsed-time buckets rather than full calendar-
    /// day-boundary logic, matching the mock data's own simulated-elapsed-time timestamps. Falls
    /// back to an actual date once a notification is more than a week old.
    private func relativeTimeString(for date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return localization.string(.justNow)
        }
        let minutes = Int(interval / 60)
        if minutes < 60 {
            return "\(minutes) \(localization.string(.minutesAgoSuffix))"
        }
        let hours = Int(interval / 3600)
        if hours < 24 {
            return "\(hours) \(localization.string(.hoursAgoSuffix))"
        }
        let days = Int(interval / 86400)
        if days == 1 {
            return localization.string(.yesterday)
        }
        if days < 7 {
            return "\(days) \(localization.string(.daysAgoSuffix))"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.load() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview {
    NavigationStack {
        NotificationsView(viewModel: NotificationsViewModel(notificationRepository: MockNotificationRepository()))
    }
    .environment(LocalizationManager())
}
