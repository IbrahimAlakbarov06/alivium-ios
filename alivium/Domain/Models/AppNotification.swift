//
//  AppNotification.swift
//  alivium
//

import Foundation

/// What kind of update a notification carries — drives the icon shown in `NotificationRow`.
enum NotificationType: String {
    case order
    case promotion
    case wishlist
    case chat

    var iconName: String {
        switch self {
        case .order: return "bag"
        case .promotion: return "tag"
        case .wishlist: return "heart"
        case .chat: return "bubble.left"
        }
    }
}

/// Named `AppNotification` rather than `Notification` to avoid shadowing Foundation's own
/// `Notification` (NSNotification) type — same reasoning as `ProductCollection` avoiding
/// stdlib's `Collection`.
struct AppNotification: Identifiable, Equatable {
    let id: String
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
}
