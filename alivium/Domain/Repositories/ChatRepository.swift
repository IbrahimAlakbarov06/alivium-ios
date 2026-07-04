//
//  ChatRepository.swift
//  alivium
//

protocol ChatRepository {
    func fetchMessages(roomId: String) async throws -> [ChatMessage]
    func sendMessage(roomId: String, text: String) async throws -> ChatMessage
}
