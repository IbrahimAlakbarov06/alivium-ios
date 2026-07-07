//
//  OrderStatusBadge.swift
//  alivium
//

import SwiftUI

/// Color-coded per status — muted gray while nothing has happened yet (or once cancelled), and
/// gold/accent for everything actively moving through to Delivered — gold reads as our brand's
/// "positive/highlight" color everywhere else in the app, so Delivered stays in that same family
/// (a bolder, filled treatment) rather than switching to an unrelated green. Shared between
/// `OrderHistoryRow` and `OrderDetailView`'s header so the two screens can never disagree on what
/// a given status looks like.
struct OrderStatusBadge: View {
    @Environment(LocalizationManager.self) private var localization
    let status: OrderStatus

    var body: some View {
        Text(localization.string(titleKey))
            .font(AppTypography.caption)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var titleKey: LocalizedKey {
        switch status {
        case .pending: return .orderStatusPending
        case .confirmed: return .orderStatusConfirmed
        case .processing: return .orderStatusProcessing
        case .shipped: return .orderStatusShipped
        case .delivered: return .orderStatusDelivered
        case .cancelled: return .orderStatusCancelled
        }
    }

    private var foregroundColor: Color {
        switch status {
        case .pending, .cancelled: return AppColor.textSecondary
        case .confirmed, .processing, .shipped: return AppColor.accentDeep
        case .delivered: return .white
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .pending, .cancelled: return AppColor.textSecondary.opacity(0.12)
        case .confirmed, .processing, .shipped: return AppColor.accent.opacity(0.18)
        case .delivered: return AppColor.accent
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.sm) {
        ForEach(OrderStatus.allCases, id: \.self) { status in
            OrderStatusBadge(status: status)
        }
    }
    .padding()
    .environment(LocalizationManager())
}
