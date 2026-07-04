//
//  LoginViewModel.swift
//  alivium
//

import Observation

@Observable
final class LoginViewModel {
    var email: String = ""
    var password: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable, matching `RegisterViewModel.register()` — the view only navigates to the
    /// main app once login actually completes, and only on the call that actually ran (guards
    /// against a rapid double-tap firing `onAuthenticated()` from a short-circuited call).
    @discardableResult
    func login() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            _ = try await authRepository.login(email: email, password: password)
            return true
        } catch {
            // Error handling comes later.
            return false
        }
    }

    @discardableResult
    func continueWithGoogle() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            _ = try await authRepository.loginWithGoogle()
            return true
        } catch {
            // Error handling comes later.
            return false
        }
    }

    @discardableResult
    func continueWithApple() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            _ = try await authRepository.loginWithApple()
            return true
        } catch {
            // Error handling comes later.
            return false
        }
    }

    func continueAsGuest() -> Bool {
        true
    }
}
