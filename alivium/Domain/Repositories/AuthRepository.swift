//
//  AuthRepository.swift
//  alivium
//

protocol AuthRepository {
    func login(email: String, password: String) async throws -> User
    func register(fullName: String, email: String, password: String) async throws -> User
    func loginWithGoogle() async throws -> User
    func loginWithApple() async throws -> User
    func forgotPassword(email: String) async throws
}
