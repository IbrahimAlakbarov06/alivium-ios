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
            VStack(spacing: AppSpacing.lg) {
                header

                Text("Create Your Account")
                    .font(AppTypography.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, AppSpacing.sm)

                VStack(spacing: AppSpacing.md) {
                    BaseTextField(placeholder: "Full Name", text: $viewModel.fullName)

                    BaseTextField(
                        placeholder: "Email Address",
                        text: $viewModel.email,
                        keyboardType: .emailAddress,
                        autocapitalization: .never,
                        disablesAutocorrection: true
                    )

                    BaseTextField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        style: .secure
                    )

                    BaseTextField(
                        placeholder: "Confirm Password",
                        text: $viewModel.confirmPassword,
                        style: .secure
                    )
                }
                .padding(.top, AppSpacing.md)

                termsText

                BaseButton(
                    title: "Create Account",
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading
                ) {
                    viewModel.register()
                }

                LabeledDivider(label: "or continue with")

                VStack(spacing: AppSpacing.sm) {
                    SocialSignInButton(provider: .google, isLoading: viewModel.isLoading) {
                        viewModel.continueWithGoogle()
                    }
                    SocialSignInButton(provider: .apple, isLoading: viewModel.isLoading) {
                        viewModel.continueWithApple()
                    }
                }

                logInFooter
                    .padding(.top, AppSpacing.sm)
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.top, AppSpacing.xl)
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.background.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
    }

    private var header: some View {
        HStack {
            Button(action: onNavigateToLogin) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
            }
            Spacer()
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
