//
//  RegisterView.swift
//  alivium
//

import SwiftUI

struct RegisterView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: RegisterViewModel
    let onNavigateToLogin: () -> Void
    let onRegisterSuccess: () -> Void
    let onAuthenticated: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderView()
                    .padding(.bottom, AppSpacing.xl)

                Text(localization.string(.createYourAccount))
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                formSection
                    .padding(.top, AppSpacing.xl)

                termsText
                    .padding(.top, AppSpacing.md)

                BaseButton(
                    title: localization.string(.createAccount),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    Task {
                        guard await viewModel.register() else { return }
                        onRegisterSuccess()
                    }
                }
                .padding(.top, AppSpacing.lg)

                LabeledDivider(label: localization.string(.orContinueWith))
                    .padding(.top, AppSpacing.xxl)

                socialButtons
                    .padding(.top, AppSpacing.md)

                logInFooter
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
            BaseTextField(placeholder: localization.string(.fullName), text: $viewModel.fullName)

            BaseTextField(
                placeholder: localization.string(.emailAddress),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                disablesAutocorrection: true
            )
            .padding(.top, AppSpacing.md)

            BaseTextField(
                placeholder: localization.string(.password),
                text: $viewModel.password,
                style: .secure
            )
            .padding(.top, AppSpacing.md)

            BaseTextField(
                placeholder: localization.string(.confirmPassword),
                text: $viewModel.confirmPassword,
                style: .secure
            )
            .padding(.top, AppSpacing.md)
        }
    }

    private var termsText: some View {
        Text(termsAttributedString)
            .font(AppTypography.caption)
            .multilineTextAlignment(.center)
    }

    /// Built from up to five localized segments — intro, the two accent-colored links, the
    /// connector between them, and a trailing outro — rather than one fixed English sentence,
    /// since AZ needs a trailing verb ("... qəbul edirsiniz.") that EN doesn't.
    private var termsAttributedString: AttributedString {
        var intro = AttributedString(localization.string(.termsAgreement) + " ")
        intro.foregroundColor = AppColor.textSecondary

        var terms = AttributedString(localization.string(.terms))
        terms.foregroundColor = AppColor.accent

        var and = AttributedString(" " + localization.string(.termsAnd) + " ")
        and.foregroundColor = AppColor.textSecondary

        var privacy = AttributedString(localization.string(.privacyPolicy))
        privacy.foregroundColor = AppColor.accent

        var result = intro + terms + and + privacy

        let outro = localization.string(.termsAgreementOutro)
        if !outro.isEmpty {
            var outroSegment = AttributedString(" " + outro)
            outroSegment.foregroundColor = AppColor.textSecondary
            result += outroSegment
        }

        return result
    }

    private var socialButtons: some View {
        VStack(spacing: AppSpacing.md) {
            SocialSignInButton(
                provider: .google,
                title: localization.string(.continueWithGoogle),
                isLoading: viewModel.isLoading
            ) {
                Task {
                    guard await viewModel.continueWithGoogle() else { return }
                    onAuthenticated()
                }
            }
            SocialSignInButton(
                provider: .apple,
                title: localization.string(.continueWithApple),
                isLoading: viewModel.isLoading
            ) {
                Task {
                    guard await viewModel.continueWithApple() else { return }
                    onAuthenticated()
                }
            }
            guestButton
        }
    }

    private var guestButton: some View {
        Button {
            guard viewModel.continueAsGuest() else { return }
            onAuthenticated()
        } label: {
            Text(localization.string(.continueAsGuest))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .disabled(viewModel.isLoading)
    }

    private var logInFooter: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text(localization.string(.alreadyHaveAccount))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button(action: onNavigateToLogin) {
                Text(localization.string(.logIn))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.accent)
            }
        }
    }
}

#Preview {
    RegisterView(
        viewModel: RegisterViewModel(authRepository: MockAuthRepository()),
        onNavigateToLogin: {},
        onRegisterSuccess: {},
        onAuthenticated: {}
    )
    .environment(LocalizationManager())
}
