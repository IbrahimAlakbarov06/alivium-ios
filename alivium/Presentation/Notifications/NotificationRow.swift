//
//  NotificationRow.swift
//  alivium
//

import SwiftUI

/// One row in the Notifications list — icon (by `NotificationType`), title/message, a relative
/// timestamp, and an unread dot + subtle background tint that distinguish unread from read.
/// Kept local to this screen rather than promoted to DesignSystem/Components, matching
/// `ProfileRow`'s own reasoning: nothing else needs this exact shape yet.
struct NotificationRow: View {
    let notification: AppNotification
    let relativeTime: String

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            iconCircle

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack(alignment: .top, spacing: AppSpacing.xs) {
                    Text(notification.title)
                        .font(notification.isRead ? AppTypography.body : AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer(minLength: AppSpacing.xs)

                    if !notification.isRead {
                        Circle()
                            .fill(AppColor.accent)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                            .accessibilityIdentifier("notificationUnreadDot-\(notification.id)")
                    }
                }

                Text(notification.message)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)

                Text(relativeTime)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary.opacity(0.7))
            }
        }
        .padding(AppSpacing.sm)
        .background(notification.isRead ? AppColor.background : AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private var iconCircle: some View {
        Image(systemName: notification.type.iconName)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(AppColor.primary)
            .frame(width: 38, height: 38)
            .background(AppColor.primary.opacity(0.1))
            .clipShape(Circle())
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        NotificationRow(
            notification: AppNotification(
                id: "1", type: .order, title: "Your order has shipped",
                message: "Order #1042 is on its way and should arrive in 3-5 days.",
                timestamp: Date(), isRead: false
            ),
            relativeTime: "2 hours ago"
        )
        NotificationRow(
            notification: AppNotification(
                id: "2", type: .promotion, title: "20% off new arrivals",
                message: "Enjoy 20% off The Autumn Edit this week only.",
                timestamp: Date(), isRead: true
            ),
            relativeTime: "Yesterday"
        )
    }
    .padding()
    .background(AppColor.backgroundOffWhite)
}
