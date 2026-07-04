//
//  ChatView.swift
//  alivium
//

import SwiftUI

struct ChatView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: ChatViewModel

    var body: some View {
        VStack(spacing: 0) {
            content
            inputBar
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(localization.string(.supportChatTitle))
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.onAppear() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            Spacer()
            ProgressView()
                .tint(AppColor.primary)
            Spacer()
        case .loaded:
            messageList
        case .error(let key):
            Spacer()
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.xl)
            Spacer()
        }
    }

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                }
                .padding(AppSpacing.md)
            }
            .onChange(of: viewModel.messages.count) {
                guard let lastId = viewModel.messages.last?.id else { return }
                withAnimation {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }

    private var inputBar: some View {
        HStack(spacing: AppSpacing.sm) {
            BaseTextField(
                placeholder: localization.string(.chatInputPlaceholder),
                text: $viewModel.draftText
            )

            Button {
                Task { await viewModel.sendMessage() }
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColor.background)
                    .frame(width: 44, height: 44)
                    .background(AppColor.primary)
                    .clipShape(Circle())
            }
            .disabled(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            .accessibilityIdentifier("chatSendButton")
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
    }
}

#Preview {
    NavigationStack {
        ChatView(viewModel: ChatViewModel(chatRepository: MockChatRepository()))
    }
    .environment(LocalizationManager())
}
