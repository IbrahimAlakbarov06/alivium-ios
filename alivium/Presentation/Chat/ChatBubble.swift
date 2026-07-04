//
//  ChatBubble.swift
//  alivium
//

import SwiftUI

/// User messages align right in primary fill; the support agent's align left in surface fill —
/// alignment and color alone communicate sender, no name label needed.
struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.senderIsUser { Spacer(minLength: 40) }

            Text(message.text)
                .font(AppTypography.body)
                .foregroundStyle(message.senderIsUser ? AppColor.background : AppColor.textPrimary)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(message.senderIsUser ? AppColor.primary : AppColor.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))

            if !message.senderIsUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: message.senderIsUser ? .trailing : .leading)
    }
}

#Preview {
    VStack(spacing: AppSpacing.sm) {
        ChatBubble(message: ChatMessage(id: "1", text: "Hi, this is Alivium Support — how can we help?", senderIsUser: false, timestamp: .now))
        ChatBubble(message: ChatMessage(id: "2", text: "I have a question about my order", senderIsUser: true, timestamp: .now))
    }
    .padding()
    .background(AppColor.backgroundOffWhite)
}
