//
//  ChatMessage.swift
//  alivium
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id: String
    let text: String
    let senderIsUser: Bool
    let timestamp: Date
}
