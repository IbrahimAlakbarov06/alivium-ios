//
//  MockAuthRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — simulates network latency and always succeeds. Swapped for a real
/// APIClient-backed implementation once the backend auth endpoints are wired (CLAUDE.md Phase 2).
final class MockAuthRepository: AuthRepository {
    func login(email: String, password: String) async throws -> User {
        try await Task.sleep(for: .seconds(1))
        return User(id: UUID().uuidString, fullName: "Alivium Member", email: email)
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
}
