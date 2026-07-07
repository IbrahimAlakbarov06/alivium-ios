//
//  ProfileView.swift
//  alivium
//

import SwiftUI

/// A marker value (no associated data) that pushes `OrderHistoryView` onto `ProfileView.path` —
/// see that property's doc comment for why this can't be a boolean/optional-driven destination.
private enum ProfileOrderHistoryRoute: Hashable {
    case show
}

struct ProfileView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: ProfileViewModel
    @State var chatViewModel: ChatViewModel
    let makeOrderHistoryViewModel: () -> OrderHistoryViewModel
    let makeOrderDetailViewModel: (Order) -> OrderDetailViewModel
    let makeAddressesViewModel: () -> AddressesViewModel
    @AppStorage("pushNotificationsEnabled") private var pushNotificationsEnabled = true
    @State private var isShowingLogOutConfirm = false
    @State private var isShowingDeleteAccountConfirm = false
    @State private var isShowingChat = false
    /// Addresses is a leaf screen (its own add/edit form is a sheet, not a further push), so the
    /// simpler `isPresented`-driven destination is safe here — same reasoning `HomeView` gives
    /// for Notifications, unlike Order History below.
    @State private var isShowingAddresses = false
    /// Shared by Order History AND Order Detail's pushes (`NavigationLink(value: order)` inside
    /// `OrderHistoryView` pushes onto this same path) — matches `HomeView.path`'s exact reasoning:
    /// an `.navigationDestination(isPresented:)`/`(item:)` destination re-asserts its own "on the
    /// path" invariant, which shoves a second push (Order Detail) right back off the stack the
    /// moment it lands on top. A single shared `NavigationPath` has no such invariant to reassert.
    @State private var path = NavigationPath()

    /// Fires once we should drop back to the Auth flow — from a confirmed Log Out, a confirmed
    /// Delete Account, or Guest tapping the header's "Log In / Sign Up" CTA directly (which
    /// needs no repository call, since a guest has no session to tear down).
    let onRequestAuthFlow: () -> Void
    /// Wired to the tab shell's Home tab — Order History's empty-state "Start Browsing" CTA.
    let onBrowseHome: () -> Void

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(spacing: AppSpacing.xxl) {
                    headerCard

                    accountSection
                    preferencesSection
                    supportSection
                    sessionSection
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppColor.backgroundOffWhite)
            .navigationDestination(isPresented: $isShowingChat) {
                ChatView(viewModel: chatViewModel)
            }
            .navigationDestination(isPresented: $isShowingAddresses) {
                AddressesView(viewModel: makeAddressesViewModel())
            }
            .navigationDestination(for: ProfileOrderHistoryRoute.self) { _ in
                OrderHistoryView(
                    viewModel: makeOrderHistoryViewModel(),
                    onBrowseHome: onBrowseHome,
                    onRequestAuthFlow: onRequestAuthFlow
                )
            }
            .navigationDestination(for: Order.self) { order in
                OrderDetailView(viewModel: makeOrderDetailViewModel(order))
            }
        }
        .confirmationDialog(
            localization.string(.logOutConfirmTitle),
            isPresented: $isShowingLogOutConfirm,
            titleVisibility: .visible
        ) {
            Button(localization.string(.logOut), role: .destructive) {
                Task {
                    guard await viewModel.logOut() else { return }
                    onRequestAuthFlow()
                }
            }
            Button(localization.string(.cancel), role: .cancel) {}
        } message: {
            Text(localization.string(.logOutConfirmMessage))
        }
        .confirmationDialog(
            localization.string(.deleteAccountConfirmTitle),
            isPresented: $isShowingDeleteAccountConfirm,
            titleVisibility: .visible
        ) {
            Button(localization.string(.deleteAccount), role: .destructive) {
                Task {
                    guard await viewModel.deleteAccount() else { return }
                    onRequestAuthFlow()
                }
            }
            Button(localization.string(.cancel), role: .cancel) {}
        } message: {
            Text(localization.string(.deleteAccountConfirmMessage))
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        HStack(spacing: AppSpacing.md) {
            avatar

            switch viewModel.sessionState {
            case .authenticated(let user):
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(user.fullName)
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColor.textPrimary)
                    Text(user.email)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                Button(action: {
                    // TODO: navigate to an Edit Profile screen once it exists.
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .accessibilityLabel(localization.string(.editProfile))

            case .guest:
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(localization.string(.guestLabel))
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    BaseButton(
                        title: localization.string(.logInOrSignUp),
                        kind: .secondary,
                        size: .small
                    ) {
                        onRequestAuthFlow()
                    }
                }

                Spacer()
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppColor.primary)

            switch viewModel.sessionState {
            case .authenticated(let user):
                Text(initials(for: user))
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
            case .guest:
                Image(systemName: "person.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .frame(width: 56, height: 56)
    }

    private func initials(for user: User) -> String {
        guard let letter = user.fullName.trimmingCharacters(in: .whitespaces).first else {
            return "A"
        }
        return String(letter).uppercased()
    }

    // MARK: - Account

    private var accountSection: some View {
        ProfileSectionCard(title: localization.string(.accountSection)) {
            ProfileRow(icon: "shippingbox", title: localization.string(.orderHistory)) {
                path.append(ProfileOrderHistoryRoute.show)
            }
            ProfileRowDivider()
            ProfileRow(icon: "mappin.and.ellipse", title: localization.string(.addresses)) {
                isShowingAddresses = true
            }
            ProfileRowDivider()
            ProfileRow(icon: "creditcard", title: localization.string(.paymentMethods)) {
                // TODO: navigate to Payment Methods once it exists.
            }
            ProfileRowDivider()
            ProfileRow(icon: "heart", title: localization.string(.wishlistTab)) {
                // TODO: deep-link to the Wishlist tab once cross-tab navigation exists.
            }
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        ProfileSectionCard(title: localization.string(.preferencesSection)) {
            preferenceRow(icon: "globe", title: localization.string(.language)) {
                LanguageToggle()
            }
            ProfileRowDivider()
            preferenceRow(icon: "bell", title: localization.string(.notifications)) {
                Toggle("", isOn: $pushNotificationsEnabled)
                    .labelsHidden()
                    .tint(AppColor.primary)
            }
        }
    }

    /// Preferences rows that end in a control (toggle/switch) rather than a chevron — not a
    /// `Button`, since the trailing control already owns its own tap target.
    private func preferenceRow<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppColor.primary)
                .frame(width: 24)

            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            trailing()
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.md)
    }

    // MARK: - Support

    private var supportSection: some View {
        ProfileSectionCard(title: localization.string(.supportSection)) {
            ProfileRow(icon: "bubble.left.and.bubble.right.fill", title: localization.string(.liveChat)) {
                isShowingChat = true
            }
            ProfileRowDivider()
            ProfileRow(icon: "questionmark.circle", title: localization.string(.helpCenter)) {
                // TODO: navigate to Help Center once it exists.
            }
            ProfileRowDivider()
            ProfileRow(icon: "envelope", title: localization.string(.contactUs)) {
                // TODO: navigate to Contact Us once it exists.
            }
            ProfileRowDivider()
            ProfileRow(icon: "star", title: localization.string(.rateTheApp)) {
                AppReviewRequester.requestReview()
            }
            ProfileRowDivider()
            ProfileRow(icon: "doc.text", title: localization.string(.termsAndPrivacyPolicy)) {
                // TODO: navigate to Terms & Privacy Policy once it exists.
            }
        }
    }

    // MARK: - Session

    private var sessionSection: some View {
        VStack(spacing: AppSpacing.lg) {
            ProfileSectionCard {
                ProfileRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    title: localization.string(.logOut),
                    titleColor: AppColor.error,
                    iconColor: AppColor.error
                ) {
                    isShowingLogOutConfirm = true
                }
            }

            Button(localization.string(.deleteAccount)) {
                isShowingDeleteAccountConfirm = true
            }
            .font(AppTypography.caption)
            .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview("Authenticated") {
    let session = UserSession()
    session.signIn(User(id: "1", fullName: "Aysel Məmmədova", email: "aysel@alivium.com"))
    return ProfileView(
        viewModel: ProfileViewModel(authRepository: MockAuthRepository(), userSession: session),
        chatViewModel: ChatViewModel(chatRepository: MockChatRepository()),
        makeOrderHistoryViewModel: { OrderHistoryViewModel(orderRepository: MockOrderRepository(), userSession: session) },
        makeOrderDetailViewModel: { order in OrderDetailViewModel(order: order, orderRepository: MockOrderRepository()) },
        makeAddressesViewModel: { AddressesViewModel(addressRepository: MockAddressRepository()) },
        onRequestAuthFlow: {},
        onBrowseHome: {}
    )
    .environment(LocalizationManager())
}

#Preview("Guest") {
    let session = UserSession()
    return ProfileView(
        viewModel: ProfileViewModel(authRepository: MockAuthRepository(), userSession: session),
        chatViewModel: ChatViewModel(chatRepository: MockChatRepository()),
        makeOrderHistoryViewModel: { OrderHistoryViewModel(orderRepository: MockOrderRepository(), userSession: session) },
        makeOrderDetailViewModel: { order in OrderDetailViewModel(order: order, orderRepository: MockOrderRepository()) },
        makeAddressesViewModel: { AddressesViewModel(addressRepository: MockAddressRepository()) },
        onRequestAuthFlow: {},
        onBrowseHome: {}
    )
    .environment(LocalizationManager())
}
