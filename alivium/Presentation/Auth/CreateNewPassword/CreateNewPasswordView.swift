//
//  CreateNewPasswordView.swift
//  alivium
//

import SwiftUI

/// Final step of the password-reset flow: Forgot Password -> Verification Code -> here.
struct CreateNewPasswordView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: CreateNewPasswordViewModel
    let onNavigateBack: () -> Void
    let onSuccess: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                BackChevronButton(action: onNavigateBack)
                    .padding(.bottom, AppSpacing.xl)

                Text(localization.string(.setNewPassword))
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(localization.string(.setNewPasswordSubtitle))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.xs)

                formSection
                    .padding(.top, AppSpacing.xl)

                BaseButton(
                    title: localization.string(.savePassword),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        guard await viewModel.savePassword() else { return }
                        onSuccess()
                    }
                }
                .padding(.top, AppSpacing.xl)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AuthBackground())
        .scrollDismissesKeyboard(.interactively)
    }

    private var formSection: some View {
        VStack(spacing: 0) {
            BaseTextField(
                placeholder: localization.string(.newPassword),
                text: $viewModel.newPassword,
                style: .secure
            )

            if !viewModel.newPassword.isEmpty {
                passwordStrengthBar
                    .padding(.top, AppSpacing.xs)
            }

            BaseTextField(
                placeholder: localization.string(.confirmPassword),
                text: $viewModel.confirmPassword,
                style: .secure,
                errorMessage: mismatchErrorMessage
            )
            .padding(.top, AppSpacing.md)
        }
    }

    private var mismatchErrorMessage: String? {
        viewModel.passwordsMatch ? nil : localization.string(.passwordsDontMatch)
    }

    private var passwordStrengthBar: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(index <= passwordStrength.rawValue ? strengthColor : AppColor.primary.opacity(0.12))
                    .frame(height: 4)
            }
        }
        .animation(.easeOut(duration: 0.2), value: passwordStrength)
    }

    /// Simple length + character-variety heuristic — a hint, not a gate: the button doesn't
    /// check this, only that the two fields are non-empty and match.
    private enum PasswordStrength: Int {
        case weak, medium, strong
    }

    private var passwordStrength: PasswordStrength {
        let password = viewModel.newPassword
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: CharacterSet.punctuationCharacters.union(.symbols)) != nil { score += 1 }
        switch score {
        case 0...1: return .weak
        case 2...3: return .medium
        default: return .strong
        }
    }

    /// Gold-to-green progression (matching the brand palette) rather than a red/yellow/green
    /// traffic light.
    private var strengthColor: Color {
        switch passwordStrength {
        case .weak: return AppColor.accentSoft
        case .medium: return AppColor.accent
        case .strong: return AppColor.primary
        }
    }
}

#Preview {
    CreateNewPasswordView(
        viewModel: CreateNewPasswordViewModel(authRepository: MockAuthRepository()),
        onNavigateBack: {},
        onSuccess: {}
    )
    .environment(LocalizationManager())
}
