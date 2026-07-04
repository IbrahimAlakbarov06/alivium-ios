//
//  ChatViewModel.swift
//  alivium
//

import Foundation
import Observation

enum ChatViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(LocalizedKey)
}

@Observable
final class ChatViewModel {
    private(set) var messages: [ChatMessage] = []
    private(set) var state: ChatViewState = .idle
    private(set) var isSending = false
    var draftText: String = ""

    private let chatRepository: ChatRepository
    private let roomId: String

    init(chatRepository: ChatRepository, roomId: String = "support") {
        self.chatRepository = chatRepository
        self.roomId = roomId
    }

    func onAppear() {
        guard state == .idle else { return }
        Task { await loadMessages() }
    }

    func loadMessages() async {
        state = .loading
        do {
            messages = try await chatRepository.fetchMessages(roomId: roomId)
            state = .loaded
        } catch {
            state = .error(.somethingWentWrong)
        }
    }

    /// Clears the draft immediately (matching iMessage-style responsiveness) rather than
    /// waiting on the round trip — safe here since the Phase 1 mock always succeeds; real
    /// failure handling (retry affordance) arrives with Phase 2 networking.
    @discardableResult
    func sendMessage() async -> Bool {
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return false }
        isSending = true
        draftText = ""
        defer { isSending = false }
        do {
            let message = try await chatRepository.sendMessage(roomId: roomId, text: trimmed)
            messages.append(message)
            return true
        } catch {
            return false
        }
    }
}
