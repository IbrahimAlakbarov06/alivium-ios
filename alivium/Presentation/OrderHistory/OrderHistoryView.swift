//
//  OrderHistoryView.swift
//  alivium
//

import SwiftUI

/// Reached from Profile's "Order History" row. Pushed onto Profile's own shared `NavigationPath`
/// (see `ProfileView.path`'s doc comment — same "second push lands on top" issue `HomeView`
/// already hit with `ProductListingSource`) rather than a `fullScreenCover`. The `NavigationLink
/// (value: order)` below pushes onto whatever `NavigationStack` this view is hosted in; the
/// matching `.navigationDestination(for: Order.self)` is registered once on `ProfileView` itself
/// rather than nested here — mirroring exactly where `HomeView` registers
/// `.navigationDestination(for: Product.self)` for pushes originating deeper in its own rails.
struct OrderHistoryView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: OrderHistoryViewModel

    /// Wired the same way as Wishlist/Cart's empty-state CTA — switches the tab shell to Home.
    let onBrowseHome: () -> Void
    /// Wired the same way as Wishlist's Guest CTA — drops back to the Auth flow.
    let onRequestAuthFlow: () -> Void

    var body: some View {
        content
            .background(AppColor.backgroundOffWhite)
            .navigationTitle(localization.string(.orderHistory))
            .navigationBarTitleDisplayMode(.inline)
            .task { viewModel.onAppear() }
            // Plain `.onAppear` (not `.task`, which only fires once for this view's lifetime)
            // so returning here after cancelling an order in Order Detail picks up its new
            // status — this view stays mounted underneath that push the whole time.
            .onAppear {
                guard viewModel.state != .idle else { return }
                Task { await viewModel.loadOrders() }
            }
    }

    @ViewBuilder
    private var content: some View {
        if case .guest = viewModel.sessionState {
            EmptyStateView(
                icon: "person.crop.circle",
                title: localization.string(.orderHistoryGuestTitle),
                subtitle: localization.string(.orderHistoryGuestSubtitle),
                actionTitle: localization.string(.logInOrSignUp),
                action: onRequestAuthFlow
            )
        } else {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .tint(AppColor.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let orders):
                list(orders)
            case .empty:
                EmptyStateView(
                    icon: "shippingbox",
                    title: localization.string(.orderHistoryEmptyTitle),
                    subtitle: localization.string(.orderHistoryEmptySubtitle),
                    actionTitle: localization.string(.startBrowsing),
                    action: onBrowseHome
                )
            case .error(let key):
                errorState(key)
            }
        }
    }

    private func list(_ orders: [Order]) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                ForEach(orders) { order in
                    NavigationLink(value: order) {
                        OrderHistoryRow(order: order)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("orderHistoryRow-\(order.id)")
                }
            }
            .padding(AppSpacing.md)
        }
        .accessibilityIdentifier("orderHistoryScrollView")
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadOrders() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview("Authenticated, loaded") {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(orderRepository: MockOrderRepository(), userSession: session),
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
        .navigationDestination(for: Order.self) { order in
            OrderDetailView(
                viewModel: OrderDetailViewModel(
                    order: order,
                    orderRepository: MockOrderRepository(),
                    reviewRepository: MockReviewRepository()
                ),
                path: .constant(NavigationPath())
            )
        }
    }
    .environment(LocalizationManager())
}

#Preview("Guest") {
    NavigationStack {
        OrderHistoryView(
            viewModel: OrderHistoryViewModel(orderRepository: MockOrderRepository(), userSession: UserSession()),
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
