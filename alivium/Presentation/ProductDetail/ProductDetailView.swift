//
//  ProductDetailView.swift
//  alivium
//

import SwiftUI

struct ProductDetailView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: ProductDetailViewModel
    @State private var galleryPage = 0
    /// Tapping a related product pushes another Product Detail on the same stack — each screen
    /// that presents this view supplies its own factory, so this stays decoupled from `AppContainer`.
    let makeProductDetailViewModel: (Product) -> ProductDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                gallery

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    header
                    variantSelectors
                    addToCartButton
                    descriptionSection
                    reviewsSection
                }
                .padding(.horizontal, AppSpacing.md)

                relatedProductsSection
                    .padding(.horizontal, AppSpacing.md)
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .background(AppColor.backgroundOffWhite)
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .top)
        .task { viewModel.onAppear() }
        // Registered once here (not buried in the conditional related-products section) so
        // tapping a related product reliably pushes another Product Detail on the same stack.
        .navigationDestination(for: Product.self) { product in
            ProductDetailView(
                viewModel: makeProductDetailViewModel(product),
                makeProductDetailViewModel: makeProductDetailViewModel
            )
        }
    }

    // MARK: - Gallery

    private var gallery: some View {
        ZStack(alignment: .bottom) {
            imagePager

            HStack {
                circleButton(icon: "chevron.left") { dismiss() }
                    .accessibilityIdentifier("productDetailBackButton")
                Spacer()
                circleButton(icon: viewModel.isWishlisted ? "heart.fill" : "heart", tint: viewModel.isWishlisted ? AppColor.accent : AppColor.textPrimary) {
                    Task { await viewModel.toggleWishlist() }
                }
                .accessibilityIdentifier("productDetailWishlistHeart")
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.xxl)
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var imagePager: some View {
        VStack(spacing: AppSpacing.sm) {
            TabView(selection: $galleryPage) {
                ForEach(Array(viewModel.product.imageNames.enumerated()), id: \.offset) { index, imageName in
                    CatalogImage(name: imageName)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(4.0 / 5.0, contentMode: .fit)

            if viewModel.product.imageNames.count > 1 {
                PageIndicator(numberOfPages: viewModel.product.imageNames.count, currentPage: galleryPage)
            }
        }
    }

    private func circleButton(icon: String, tint: Color = AppColor.textPrimary, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.9))
                .clipShape(Circle())
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(viewModel.product.name)
                .font(AppTypography.title)
                .foregroundStyle(AppColor.textPrimary)

            PriceLabel(price: viewModel.product.price, discountPrice: viewModel.product.discountPrice)

            RatingView(rating: viewModel.product.averageRating, reviewCount: viewModel.product.reviewCount)
        }
    }

    // MARK: - Variant selectors

    @ViewBuilder
    private var variantSelectors: some View {
        if !viewModel.availableSizes.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(localization.string(.selectSize))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)

                HStack(spacing: AppSpacing.xs) {
                    ForEach(viewModel.availableSizes, id: \.self) { size in
                        CategoryChip(title: size, isSelected: viewModel.selectedSize == size) {
                            viewModel.selectSize(size)
                        }
                    }
                }
            }
        }

        if !viewModel.availableColors.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(localization.string(.selectColor))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)

                HStack(spacing: AppSpacing.xs) {
                    ForEach(viewModel.availableColors, id: \.self) { color in
                        CategoryChip(title: color, isSelected: viewModel.selectedColor == color) {
                            viewModel.selectColor(color)
                        }
                    }
                }
            }
        }
    }

    private var addToCartButton: some View {
        BaseButton(
            title: viewModel.didAddToCart ? localization.string(.addedToCart) : localization.string(.addToCart),
            kind: .primary,
            size: .large,
            isLoading: viewModel.isAddingToCart,
            isEnabled: viewModel.canAddToCart
        ) {
            Task { await viewModel.addToCart() }
        }
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            SectionHeader(title: localization.string(.descriptionSectionTitle))

            Text(viewModel.product.description)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }

    // MARK: - Reviews

    @ViewBuilder
    private var reviewsSection: some View {
        if !viewModel.reviews.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(title: localization.string(.reviewsSectionTitle))

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ForEach(viewModel.reviews) { review in
                        ReviewRow(review: review)
                    }
                }
            }
        }
    }

    // MARK: - Related products

    @ViewBuilder
    private var relatedProductsSection: some View {
        if !viewModel.relatedProducts.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                SectionHeader(title: localization.string(.youMightAlsoLike))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        ForEach(viewModel.relatedProducts) { product in
                            NavigationLink(value: product) {
                                ProductCard(product: product, layout: .rail)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    let product = MockProductRepository.featuredProducts[0]
    return NavigationStack {
        ProductDetailView(
            viewModel: ProductDetailViewModel(
                product: product,
                productRepository: MockProductRepository(),
                reviewRepository: MockReviewRepository(),
                cartRepository: MockCartRepository(),
                wishlistRepository: MockWishlistRepository()
            ),
            makeProductDetailViewModel: { product in
                ProductDetailViewModel(
                    product: product,
                    productRepository: MockProductRepository(),
                    reviewRepository: MockReviewRepository(),
                    cartRepository: MockCartRepository(),
                    wishlistRepository: MockWishlistRepository()
                )
            }
        )
    }
    .environment(LocalizationManager())
}
