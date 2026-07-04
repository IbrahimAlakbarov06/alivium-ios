//
//  MockChatRepository.swift
//  alivium
//

import Foundation

/// Phase 1 stand-in — swapped for a real WebSocket-backed implementation once the backend's
/// ChatRoom/ChatMessage endpoints are wired (CLAUDE.md Phase 2).
final class MockChatRepository: ChatRepository {
    func fetchMessages(roomId: String) async throws -> [ChatMessage] {
        try await Task.sleep(for: .seconds(0.6))
        return [
            ChatMessage(
                id: UUID().uuidString,
                text: "Hi, this is Alivium Support — how can we help you today?",
                senderIsUser: false,
                timestamp: Date().addingTimeInterval(-600)
            )
        ]
    }

    func sendMessage(roomId: String, text: String) async throws -> ChatMessage {
        try await Task.sleep(for: .seconds(0.3))
        return ChatMessage(id: UUID().uuidString, text: text, senderIsUser: true, timestamp: Date())
    }
}
