//
//  CartView.swift
//  alivium
//

import SwiftUI

struct CartView: View {
    @Environment(LocalizationManager.self) private var localization
    @State var viewModel: CartViewModel
    @State private var isPromoCodeExpanded = false
    /// Built lazily — the moment "Proceed to Checkout" is tapped — so it snapshots whatever
    /// `viewModel.items`/`selectedShippingMethod` actually are at that instant, rather than a
    /// live reference that would keep changing under the checkout flow's feet. Presentation is
    /// driven directly off this optional via `.fullScreenCover(item:)` rather than a separate
    /// `Bool` — a `Bool` set alongside the optional in the same action races the cover's content
    /// closure, which can fire while the optional is still nil.
    @State private var checkoutViewModel: CheckoutViewModel?
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel
    let makeCheckoutViewModel: ([CartItem], ShippingMethod) -> CheckoutViewModel

    /// Wired to the tab shell's Home tab — "Start Browsing" from the empty state, and also where
    /// Checkout's "Back to Home" on a completed order lands.
    let onBrowseHome: () -> Void
    /// Wired the same way as Profile/Wishlist's Guest CTA — drops back to the Auth flow, needed
    /// here so a pushed Product Detail's wishlist-heart sign-in prompt has somewhere to go.
    let onRequestAuthFlow: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)

            content
        }
        .background(AppColor.backgroundOffWhite)
        .task { viewModel.onAppear() }
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(
                viewModel: makeProductDetailViewModel(product),
                makeProductDetailViewModel: makeProductDetailViewModel,
                onRequestAuthFlow: onRequestAuthFlow
            )
        }
        .fullScreenCover(item: $checkoutViewModel) { checkoutViewModel in
            CheckoutFlowView(
                viewModel: checkoutViewModel,
                onCancel: { self.checkoutViewModel = nil },
                onOrderComplete: {
                    self.checkoutViewModel = nil
                    onBrowseHome()
                }
            )
        }
    }

    private var topBar: some View {
        HStack {
            Text(localization.string(.cartTab))
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)
            Spacer()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .tint(AppColor.primary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .empty:
            EmptyStateView(
                icon: "bag",
                title: localization.string(.cartEmptyTitle),
                subtitle: localization.string(.cartEmptySubtitle),
                actionTitle: localization.string(.startBrowsing),
                action: onBrowseHome
            )
        case .loaded:
            loadedContent
        case .error(let key):
            errorState(key)
        }
    }

    // MARK: - Loaded

    private var loadedContent: some View {
        ScrollView {
            VStack(spacing: AppSpacing.xl) {
                lineItems
                promoCodeCard
                shippingCard
                summaryCard
            }
            .padding(AppSpacing.md)
        }
    }

    private var lineItems: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(viewModel.items) { item in
                NavigationLink(value: item.product) {
                    CartLineItemRow(
                        item: item,
                        onQuantityChange: { newQuantity in
                            viewModel.updateQuantity(for: item, to: newQuantity)
                        },
                        onRemove: {
                            Task { await viewModel.remove(item) }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Promo code

    /// Collapsed by default so an empty code field doesn't compete for attention — expands into
    /// the input only once the shopper actually wants to use one.
    private var promoCodeCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isPromoCodeExpanded.toggle() }
            } label: {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "tag")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppColor.accent)

                    Text(localization.string(.havePromoCode))
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Image(systemName: isPromoCodeExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isPromoCodeExpanded {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.sm) {
                        BaseTextField(
                            placeholder: localization.string(.voucherCodePlaceholder),
                            text: $viewModel.voucherCode
                        )

                        BaseButton(title: localization.string(.apply), kind: .secondary, size: .medium) {
                            viewModel.applyVoucher()
                        }
                    }

                    if viewModel.isVoucherApplied {
                        Label(localization.string(.voucherApplied), systemImage: "checkmark.circle.fill")
                            .font(AppTypography.caption)
                            .foregroundStyle(AppColor.accent)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Shipping

    private var shippingCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(localization.string(.shippingSectionTitle))
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)

            VStack(spacing: AppSpacing.xxs) {
                ForEach(ShippingMethod.allCases) { method in
                    shippingRow(method)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func shippingRow(_ method: ShippingMethod) -> some View {
        let isSelected = viewModel.selectedShippingMethod == method

        return Button {
            viewModel.selectedShippingMethod = method
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? AppColor.primary : AppColor.textSecondary.opacity(0.35))

                VStack(alignment: .leading, spacing: 2) {
                    Text(shippingName(for: method))
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                    Text("\(method.days) \(localization.string(.shippingDaysSuffix))")
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()

                if method.price.minorUnits > 0 {
                    Text(method.price.formatted)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)
                }
            }
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.sm)
            .background(isSelected ? AppColor.primary.opacity(0.06) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
        }
        .buttonStyle(.plain)
    }

    private func shippingName(for method: ShippingMethod) -> String {
        switch method {
        case .free: return localization.string(.shippingFree)
        case .standard: return localization.string(.shippingStandard)
        case .fast: return localization.string(.shippingFast)
        }
    }

    // MARK: - Summary

    private var summaryCard: some View {
        VStack(spacing: AppSpacing.md) {
            VStack(spacing: AppSpacing.sm) {
                summaryRow(title: localization.string(.subtotal), value: viewModel.subtotal.formatted)
                Divider()
                summaryRow(title: localization.string(.total), value: viewModel.total.formatted, emphasized: true)
            }

            BaseButton(title: localization.string(.proceedToCheckout), kind: .primary, size: .large) {
                checkoutViewModel = makeCheckoutViewModel(viewModel.items, viewModel.selectedShippingMethod)
            }
            .accessibilityIdentifier("proceedToCheckoutButton")
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func summaryRow(title: String, value: String, emphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(emphasized ? AppTypography.headline : AppTypography.body)
                .foregroundStyle(emphasized ? AppColor.textPrimary : AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(emphasized ? AppTypography.title : AppTypography.bodyEmphasis)
                .foregroundStyle(emphasized ? AppColor.primary : AppColor.textPrimary)
        }
    }

    private func errorState(_ key: LocalizedKey) -> some View {
        VStack(spacing: AppSpacing.md) {
            Text(localization.string(key))
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)

            BaseButton(title: localization.string(.tryAgain), kind: .primary, size: .medium) {
                Task { await viewModel.loadCart() }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppSpacing.xl)
    }
}

#Preview {
    NavigationStack {
        CartView(
            viewModel: CartViewModel(cartRepository: MockCartRepository(), cartBadgeStore: CartBadgeStore()),
            makeProductDetailViewModel: { product in
                ProductDetailViewModel(
                    product: product,
                    productRepository: MockProductRepository(),
                    reviewRepository: MockReviewRepository(),
                    cartRepository: MockCartRepository(),
                    wishlistRepository: MockWishlistRepository(),
                    cartBadgeStore: CartBadgeStore(),
                    userSession: UserSession()
                )
            },
            makeCheckoutViewModel: { items, shippingMethod in
                CheckoutViewModel(
                    items: items,
                    selectedShippingMethod: shippingMethod,
                    addressRepository: MockAddressRepository(),
                    cartRepository: MockCartRepository(),
                    orderRepository: MockOrderRepository(),
                    cartBadgeStore: CartBadgeStore()
                )
            },
            onBrowseHome: {},
            onRequestAuthFlow: {}
        )
    }
    .environment(LocalizationManager())
}
