//
//  MockAuthRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — simulates network latency and always succeeds. Swapped for a real
/// APIClient-backed implementation once the backend auth endpoints are wired (CLAUDE.md Phase 2).
final class MockAuthRepository: AuthRepository {
    /// The only password every UI test/manual login actually uses — real enough to give Change
    /// Password's "wrong current password" path something legitimate to fail against, since
    /// `login` itself accepts any password.
    private static let mockCurrentPassword = "password123"

    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: UUID().uuidString, fullName: "Alivium Member", email: email, phone: "+994 50 123 45 67")
    }

    func register(fullName: String, email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: UUID().uuidString, fullName: fullName, email: email)
    }

    func loginWithGoogle() async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: UUID().uuidString, fullName: "Google User", email: "google.user@alivium.com")
    }

    func loginWithApple() async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: UUID().uuidString, fullName: "Apple User", email: "apple.user@alivium.com")
    }

    func forgotPassword(email: String) async throws {
        try await Task.sleep(for: .seconds(1))
    }

    func verifyCode(_ code: String) async throws {
        try await Task.sleep(for: .seconds(1))
    }

    func resetPassword(newPassword: String) async throws {
        try await Task.sleep(for: .seconds(1))
    }

    func logOut() async throws {
        try await Task.sleep(for: .seconds(0.3))
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(0.3))
    }

    func updateProfile(id: String, fullName: String, email: String, phone: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: id, fullName: fullName, email: email, phone: phone)
    }

    func changePassword(currentPassword: String, newPassword: String) async throws {
        try await Task.sleep(for: .seconds(1))
        guard currentPassword == Self.mockCurrentPassword else {
            throw AuthError.incorrectCurrentPassword
        }
    }
}
