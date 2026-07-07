//
//  NotificationsViewState.swift
//  alivium
//

enum NotificationsViewState: Equatable {
    case idle
    case loading
    case loaded([AppNotification])
    case empty
    case error(LocalizedKey)
}
