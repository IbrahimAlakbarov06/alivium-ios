//
//  CheckoutFlowView.swift
//  alivium
//

import SwiftUI

private enum CheckoutRoute {
    case address
    case payment
    case confirmation(orderNumber: String)
}

/// Address -> Payment -> Confirmation, coordinated the same way `AuthFlowView` coordinates its
/// own multi-screen flow (CLAUDE.md Phase 1, item 3) — a local route enum switched via closures,
/// not a `NavigationStack` push per step, since every step shares the same `CheckoutViewModel` and
/// there's no independent back-stack behavior needed beyond what these closures already express.
/// Presented as a `.fullScreenCover` from `CartView`.
struct CheckoutFlowView: View {
    @State private var route: CheckoutRoute = .address
    @State var viewModel: CheckoutViewModel
    /// Leaving the flow without completing it (the Address step's `xmark`) — dismisses the cover,
    /// stays on Cart.
    let onCancel: () -> Void
    /// Reaching Confirmation and tapping "Back to Home" — dismisses the cover AND switches to the
    /// Home tab, matching the task's explicit ask for a way back to browsing after a real purchase.
    let onOrderComplete: () -> Void

    var body: some View {
        Group {
            switch route {
            case .address:
                CheckoutAddressView(
                    viewModel: viewModel,
                    onCancel: onCancel,
                    onContinue: { withAnimation { route = .payment } }
                )
            case .payment:
                CheckoutPaymentView(
                    viewModel: viewModel,
                    onBack: { withAnimation { route = .address } },
                    onPlaceOrder: { orderNumber in
                        withAnimation { route = .confirmation(orderNumber: orderNumber) }
                    }
                )
            case .confirmation(let orderNumber):
                OrderConfirmationView(
                    viewModel: viewModel,
                    orderNumber: orderNumber,
                    onDone: onOrderComplete
                )
            }
        }
        .transition(.opacity)
    }
}

#Preview {
    CheckoutFlowView(
        viewModel: CheckoutViewModel(
            items: [],
            selectedShippingMethod: .standard,
            addressRepository: MockAddressRepository(),
            cartRepository: MockCartRepository(),
            orderRepository: MockOrderRepository(),
            cartBadgeStore: CartBadgeStore()
        ),
        onCancel: {},
        onOrderComplete: {}
    )
    .environment(LocalizationManager())
}
