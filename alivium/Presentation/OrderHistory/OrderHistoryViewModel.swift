//
//  OrderHistoryViewModel.swift
//  alivium
//

import Observation

@Observable
final class OrderHistoryViewModel {
    private(set) var state: OrderHistoryViewState = .idle

    private let orderRepository: OrderRepository
    private let userSession: UserSession

    var sessionState: UserSessionState {
        userSession.state
    }

    init(orderRepository: OrderRepository, userSession: UserSession) {
        self.orderRepository = orderRepository
        self.userSession = userSession
    }

    func onAppear() {
        // A guest has no persisted order history — the View shows a sign-in prompt instead, so
        // there's nothing to fetch (matches WishlistViewModel's identical guest gating).
        guard case .authenticated = userSession.state else { return }
        guard state == .idle else { return }
        Task { await loadOrders() }
    }

    func loadOrders() async {
        state = .loading
        do {
            let orders = try await orderRepository.fetchOrders()
            state = orders.isEmpty ? .empty : .loaded(orders)
        } catch {
            state = .error(.somethingWentWrong)
        }
    }
}
