//
//  RegisterViewModel.swift
//  alivium
//

import Observation

@Observable
final class RegisterViewModel {
    var fullName: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    private(set) var state: AuthViewState = .idle

    var isLoading: Bool { state == .loading }

    private let authRepository: AuthRepository

    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    /// Awaitable, matching `ForgotPasswordViewModel.sendResetLink()` — the view chains
    /// navigation to the Verification Code screen only once registration actually completes.
    ///
    /// Returns whether this call actually performed the registration (vs. short-circuiting on
    /// the `isLoading` guard) — a rapid double-tap can fire two `Task { await register() }`
    /// calls before the first one's `state = .loading` has taken effect, so the caller must
    /// only navigate on the call that actually ran, not on every call that merely returned.
    @discardableResult
    func register() async -> Bool {
        guard state != .loading else { return false }
        state = .loading
        defer { state = .idle }
        do {
            _ = try await authRepository.register(fullName: fullName, email: email, password: password)
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
