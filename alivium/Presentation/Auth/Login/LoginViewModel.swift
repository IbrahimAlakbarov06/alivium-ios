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

    func login() {
        guard state != .loading else { return }
        state = .loading
        Task {
            defer { state = .idle }
            do {
                _ = try await authRepository.login(email: email, password: password)
                print("Login succeeded — TODO: navigate to next screen")
            } catch {
                // Error handling comes later.
            }
        }
    }

    func continueWithGoogle() {
        guard state != .loading else { return }
        state = .loading
        Task {
            defer { state = .idle }
            do {
                _ = try await authRepository.loginWithGoogle()
                print("Google sign-in succeeded — TODO: navigate to next screen")
            } catch {
                // Error handling comes later.
            }
        }
    }

    func continueWithApple() {
        guard state != .loading else { return }
        state = .loading
        Task {
            defer { state = .idle }
            do {
                _ = try await authRepository.loginWithApple()
                print("Apple sign-in succeeded — TODO: navigate to next screen")
            } catch {
                // Error handling comes later.
            }
        }
    }

    func continueAsGuest() {
        print("Continuing as guest — TODO: navigate to next screen")
    }
}
