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

    func register() {
        guard state != .loading else { return }
        state = .loading
        Task {
            defer { state = .idle }
            do {
                _ = try await authRepository.register(fullName: fullName, email: email, password: password)
                print("Registration succeeded — TODO: navigate to next screen")
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
