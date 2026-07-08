//
//  EditProfileView.swift
//  alivium
//

import SwiftUI

/// Reached from Profile's header card chevron — authenticated users only, since the chevron
/// itself only exists in `ProfileView.headerCard`'s `.authenticated` branch (a Guest has no
/// profile to edit). Pushed onto Profile's own shared `NavigationPath` (see that property's doc
/// comment) rather than a simple `isPresented`-driven destination — Change Password pushes a
/// second level on top of this screen, the same "second push lands on top" shape Order History
/// -> Order Detail already hit, so both are routed through the one shared path.
struct EditProfileView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: EditProfileViewModel
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                formSection
                changePasswordSection

                BaseButton(
                    title: localization.string(.saveChanges),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isProcessing,
                    isEnabled: viewModel.canSave
                ) {
                    Task {
                        if await viewModel.saveChanges() {
                            dismiss()
                        }
                    }
                }
                .accessibilityIdentifier("saveProfileChangesButton")
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(localization.string(.editProfile))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formSection: some View {
        VStack(spacing: AppSpacing.md) {
            BaseTextField(placeholder: localization.string(.fullName), text: $viewModel.fullName)
            BaseTextField(
                placeholder: localization.string(.emailAddress),
                text: $viewModel.email,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            BaseTextField(
                placeholder: localization.string(.phoneNumberPlaceholder),
                text: $viewModel.phone,
                keyboardType: .phonePad,
                prefix: "+994"
            )
        }
    }

    private var changePasswordSection: some View {
        ProfileSectionCard {
            ProfileRow(icon: "lock", title: localization.string(.changePassword)) {
                path.append(ProfileEditRoute.changePassword)
            }
        }
        .accessibilityIdentifier("changePasswordRow")
    }
}

#Preview {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return NavigationStack {
        EditProfileView(
            viewModel: EditProfileViewModel(userSession: session, authRepository: MockAuthRepository()),
            path: .constant(NavigationPath())
        )
    }
    .environment(LocalizationManager())
}
