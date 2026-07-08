//
//  ChangePasswordView.swift
//  alivium
//

import SwiftUI

/// Pushed from `EditProfileView` — a leaf screen (nothing pushes further from here), reached via
/// `path.append(ProfileEditRoute.changePassword)` onto Profile's shared `NavigationPath`.
struct ChangePasswordView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ChangePasswordViewModel
    @State private var isShowingSuccessAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                BaseTextField(
                    placeholder: localization.string(.currentPassword),
                    text: $viewModel.currentPassword,
                    style: .secure,
                    errorMessage: currentPasswordErrorMessage
                )

                BaseTextField(
                    placeholder: localization.string(.newPassword),
                    text: $viewModel.newPassword,
                    style: .secure
                )

                BaseTextField(
                    placeholder: localization.string(.confirmPassword),
                    text: $viewModel.confirmPassword,
                    style: .secure,
                    errorMessage: mismatchErrorMessage
                )

                BaseButton(
                    title: localization.string(.updatePassword),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isLoading,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task {
                        if await viewModel.updatePassword() {
                            isShowingSuccessAlert = true
                        }
                    }
                }
                .accessibilityIdentifier("updatePasswordButton")
                .padding(.top, AppSpacing.sm)
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(localization.string(.changePassword))
        .navigationBarTitleDisplayMode(.inline)
        .alert(
            localization.string(.passwordUpdatedTitle),
            isPresented: $isShowingSuccessAlert
        ) {
            Button(localization.string(.ok)) { dismiss() }
        } message: {
            Text(localization.string(.passwordUpdatedMessage))
        }
    }

    private var mismatchErrorMessage: String? {
        viewModel.passwordsMatch ? nil : localization.string(.passwordsDontMatch)
    }

    private var currentPasswordErrorMessage: String? {
        viewModel.currentPasswordErrorMessage.map(localization.string)
    }
}

#Preview {
    NavigationStack {
        ChangePasswordView(viewModel: ChangePasswordViewModel(authRepository: MockAuthRepository()))
    }
    .environment(LocalizationManager())
}
