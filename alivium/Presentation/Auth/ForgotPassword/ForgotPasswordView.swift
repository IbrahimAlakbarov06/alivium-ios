//
//  ForgotPasswordView.swift
//  alivium
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: ForgotPasswordViewModel
    let onNavigateBack: () -> Void
    let onSuccess: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                backButton
                    .padding(.bottom, AppSpacing.xl)

                Text(localization.string(.resetYourPassword))
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(localization.string(.resetPasswordSubtitle))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.xs)

                BaseTextField(
                    placeholder: localization.string(.emailAddress),
                    text: $viewModel.email,
                    keyboardType: .emailAddress,
                    autocapitalization: .never,
                    disablesAutocorrection: true
                )
                .padding(.top, AppSpacing.xl)

                BaseButton(
                    title: localization.string(.sendResetLink),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        await viewModel.sendResetLink()
                        onSuccess()
                    }
                }
                .padding(.top, AppSpacing.lg)

                backToLoginLink
                    .padding(.top, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AuthBackground())
        .scrollDismissesKeyboard(.interactively)
    }

    private var backButton: some View {
        HStack {
            Button(action: onNavigateBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            .accessibilityLabel(localization.string(.back))
            Spacer()
        }
    }

    private var backToLoginLink: some View {
        Button(action: onNavigateBack) {
            Text(localization.string(.backToLogIn))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.accent)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ForgotPasswordView(
        viewModel: ForgotPasswordViewModel(authRepository: MockAuthRepository()),
        onNavigateBack: {},
        onSuccess: {}
    )
    .environment(LocalizationManager())
}
