//
//  RegisterView.swift
//  alivium
//

import SwiftUI

struct RegisterView: View {
    @State var viewModel: RegisterViewModel
    let onNavigateToLogin: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                AuthHeaderView()
                    .padding(.bottom, AppSpacing.xl)

                Text("Create Your Account")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppSpacing.md)

                formSection
                    .padding(.top, AppSpacing.xl)

                termsText
                    .padding(.top, AppSpacing.md)

                BaseButton(
                    title: "Create Account",
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.register()
                }
                .padding(.top, AppSpacing.lg)

                LabeledDivider(label: "or continue with")
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
            BaseTextField(placeholder: "Full Name", text: $viewModel.fullName)

            BaseTextField(
                placeholder: "Email Address",
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never,
                disablesAutocorrection: true
            )
            .padding(.top, AppSpacing.md)

            BaseTextField(
                placeholder: "Password",
                text: $viewModel.password,
                style: .secure
            )
            .padding(.top, AppSpacing.md)

            BaseTextField(
                placeholder: "Confirm Password",
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

    private var termsAttributedString: AttributedString {
        var intro = AttributedString("By continuing, you agree to our ")
        intro.foregroundColor = AppColor.textSecondary

        var terms = AttributedString("Terms")
        terms.foregroundColor = AppColor.accent

        var and = AttributedString(" and ")
        and.foregroundColor = AppColor.textSecondary

        var privacy = AttributedString("Privacy Policy")
        privacy.foregroundColor = AppColor.accent

        return intro + terms + and + privacy
    }

    private var socialButtons: some View {
        VStack(spacing: AppSpacing.md) {
            SocialSignInButton(provider: .google, isLoading: viewModel.isLoading) {
                viewModel.continueWithGoogle()
            }
            SocialSignInButton(provider: .apple, isLoading: viewModel.isLoading) {
                viewModel.continueWithApple()
            }
            guestButton
        }
    }

    private var guestButton: some View {
        Button {
            viewModel.continueAsGuest()
        } label: {
            Text("Continue as Guest")
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .disabled(viewModel.isLoading)
    }

    private var logInFooter: some View {
        HStack(spacing: AppSpacing.xxs) {
            Text("Already have an account?")
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)

            Button(action: onNavigateToLogin) {
                Text("Log In")
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.accent)
            }
        }
    }
}

#Preview {
    RegisterView(
        viewModel: RegisterViewModel(authRepository: MockAuthRepository()),
        onNavigateToLogin: {}
    )
}
