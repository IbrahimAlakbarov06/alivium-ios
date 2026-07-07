//
//  OrderDetailView.swift
//  alivium
//

import SwiftUI

/// Pushed from `OrderHistoryView`. Full line-item breakdown, the address/shipping/payment used,
/// a status timeline, and the price breakdown — everything Order History's row only summarizes.
struct OrderDetailView: View {
    @Environment(LocalizationManager.self) private var localization
    let viewModel: OrderDetailViewModel

    private var order: Order { viewModel.order }

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                headerCard
                statusCard
                itemsCard
                addressCard
                orderInfoCard
                totalsCard
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(localization.string(.orderDetailTitle))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text("#\(order.orderNumber)")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Text("\(localization.string(.orderPlacedOnLabel)) \(Self.dateFormatter.string(from: order.placedAt))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
            Spacer()
            OrderStatusBadge(status: order.status)
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Status timeline

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(localization.string(.orderStatusSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            if order.status == .cancelled {
                Label(localization.string(.orderCancelledMessage), systemImage: "xmark.circle")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.error)
            } else {
                statusTimeline
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var statusTimeline: some View {
        let stages = OrderStatus.progression
        let currentIndex = stages.firstIndex(of: order.status) ?? 0

        return VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(stages.enumerated()), id: \.element) { index, stage in
                timelineRow(stage: stage, index: index, currentIndex: currentIndex, isLast: index == stages.count - 1)
            }
        }
    }

    private func timelineRow(stage: OrderStatus, index: Int, currentIndex: Int, isLast: Bool) -> some View {
        let isCompleted = index < currentIndex
        let isCurrent = index == currentIndex
        let isReached = index <= currentIndex

        return HStack(alignment: .top, spacing: AppSpacing.sm) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isReached ? AppColor.primary : AppColor.surface)
                        .overlay(
                            Circle().stroke(isReached ? AppColor.primary : AppColor.textSecondary.opacity(0.3), lineWidth: 1.5)
                        )
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(width: 16, height: 16)

                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? AppColor.primary : AppColor.textSecondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(minHeight: 24)
                }
            }

            Text(statusTitle(for: stage))
                .font(isCurrent ? AppTypography.bodyEmphasis : AppTypography.body)
                .foregroundStyle(isReached ? AppColor.textPrimary : AppColor.textSecondary)
                .padding(.bottom, isLast ? 0 : AppSpacing.md)

            Spacer(minLength: 0)
        }
    }

    private func statusTitle(for status: OrderStatus) -> String {
        switch status {
        case .pending: return localization.string(.orderStatusPending)
        case .confirmed: return localization.string(.orderStatusConfirmed)
        case .processing: return localization.string(.orderStatusProcessing)
        case .shipped: return localization.string(.orderStatusShipped)
        case .delivered: return localization.string(.orderStatusDelivered)
        case .cancelled: return localization.string(.orderStatusCancelled)
        }
    }

    // MARK: - Items

    private var itemsCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(localization.string(.orderItemsSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.md) {
                ForEach(order.items) { item in
                    OrderLineItemRow(item: item)
                    if item.id != order.items.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Address

    private var addressCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(localization.string(.checkoutAddressTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
                .padding(.bottom, AppSpacing.xxs)

            Text(order.address.label)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
            Text(order.address.fullName)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textPrimary)
            Text("\(order.address.addressLine), \(order.address.city)")
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
            Text(order.address.phone)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Shipping + payment

    private var orderInfoCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(localization.string(.orderInfoSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            infoRow(title: localization.string(.shippingSectionTitle), value: shippingMethodName)
            Divider()
            infoRow(title: localization.string(.paymentMethodSectionTitle), value: paymentMethodName)
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private var shippingMethodName: String {
        switch order.shippingMethod {
        case .free: return localization.string(.shippingFree)
        case .standard: return localization.string(.shippingStandard)
        case .fast: return localization.string(.shippingFast)
        }
    }

    private var paymentMethodName: String {
        switch order.paymentMethod {
        case .cashOnDelivery: return localization.string(.cashOnDelivery)
        case .card: return localization.string(.creditDebitCard)
        }
    }

    // MARK: - Totals

    private var totalsCard: some View {
        VStack(spacing: AppSpacing.sm) {
            infoRow(title: localization.string(.subtotal), value: order.subtotal.formatted)
            infoRow(
                title: localization.string(.shippingSectionTitle),
                value: order.shippingCost.minorUnits > 0 ? order.shippingCost.formatted : localization.string(.shippingFree)
            )
            Divider()
            infoRow(title: localization.string(.total), value: order.total.formatted, emphasized: true)
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func infoRow(title: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasized ? AppTypography.headline : AppTypography.body)
                .foregroundStyle(emphasized ? AppColor.textPrimary : AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(emphasized ? AppTypography.title : AppTypography.bodyEmphasis)
                .foregroundStyle(emphasized ? AppColor.primary : AppColor.textPrimary)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}

#Preview {
    NavigationStack {
        OrderDetailView(
            viewModel: OrderDetailViewModel(
                order: Order(
                    id: "order-1", orderNumber: "AL-58213",
                    items: [
                        CartItem(
                            id: "oi-1",
                            product: Product(
                                id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                                imageNames: [], categoryId: "dresses", variants: [],
                                description: "", averageRating: 4.7, reviewCount: 132
                            ),
                            selectedVariant: ProductVariant(id: "Ivory-M", size: "M", color: "Ivory", stockQuantity: 8),
                            quantity: 1
                        )
                    ],
                    address: Address(
                        id: "addr-1", label: "Home", fullName: "Aysel Məmmədova", phone: "+994 50 123 45 67",
                        addressLine: "28 May küç. 15", city: "Bakı", postalCode: "AZ1000"
                    ),
                    shippingMethod: .standard, paymentMethod: .cashOnDelivery, status: .shipped,
                    subtotal: Money(189.00), placedAt: Date()
                )
            )
        )
    }
    .environment(LocalizationManager())
}
