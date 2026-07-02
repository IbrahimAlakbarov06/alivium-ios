//
//  ForgotPasswordViewModel.swift
//  alivium
//

import Observation

@Observable
final class ForgotPasswordViewModel {
    var email: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable — unlike Login/Register's fire-and-forget internal `Task { ... }` — so the
    /// view can navigate to the next screen only once the send actually completes.
    func sendResetLink() async {
        guard state != .loading else { return }
        state = .loading
        defer { state = .idle }
        do {
            try await authRepository.forgotPassword(email: email)
        } catch {
            // Error handling comes later, consistent with Login/Register.
        }
    }
}
