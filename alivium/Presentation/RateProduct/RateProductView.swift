//
//  RateProductView.swift
//  alivium
//

import SwiftUI
import PhotosUI

/// Pushed from Order Detail's line items (Delivered orders only) onto Profile's shared
/// `NavigationPath` — see `ProfileView.path`'s doc comment for why a screen reached from a
/// pushed view needs that shared-path treatment rather than a simpler `isPresented` destination.
struct RateProductView: View {
    @Environment(LocalizationManager.self) private var localization
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: RateProductViewModel

    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isShowingCamera = false
    @State private var isShowingSuccessAlert = false
    @FocusState private var isReviewTextFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                productSummary
                ratingSection
                reviewTextSection
                photosSection

                BaseButton(
                    title: localization.string(.submitReview),
                    kind: .primary,
                    size: .large,
                    isLoading: viewModel.isSubmitting,
                    isEnabled: viewModel.canSubmit
                ) {
                    Task {
                        if await viewModel.submitReview() {
                            isShowingSuccessAlert = true
                        }
                    }
                }
                .accessibilityIdentifier("submitReviewButton")
            }
            .padding(AppSpacing.md)
        }
        .background(AppColor.backgroundOffWhite)
        .navigationTitle(localization.string(.rateProduct))
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .fullScreenCover(isPresented: $isShowingCamera) {
            CameraPicker(
                onImagePicked: { data in
                    viewModel.addPhoto(data)
                    isShowingCamera = false
                },
                onCancel: { isShowingCamera = false }
            )
            .ignoresSafeArea()
        }
        .alert(
            localization.string(.reviewSubmittedTitle),
            isPresented: $isShowingSuccessAlert
        ) {
            Button(localization.string(.ok)) { dismiss() }
        } message: {
            Text(localization.string(.reviewSubmittedMessage))
        }
        .onChange(of: photoPickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task {
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        viewModel.addPhoto(data)
                    }
                }
                photoPickerItems = []
            }
        }
    }

    // MARK: - Product summary

    private var productSummary: some View {
        HStack(spacing: AppSpacing.sm) {
            CatalogImage(name: viewModel.product.primaryImageName)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))

            Text(viewModel.product.name)
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.sm)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Rating

    private var ratingSection: some View {
        VStack(spacing: AppSpacing.sm) {
            InteractiveRatingView(rating: $viewModel.rating)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    // MARK: - Review text

    private var reviewTextSection: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.reviewText.isEmpty {
                Text(localization.string(.reviewTextPlaceholder))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textSecondary.opacity(0.6))
                    .padding(.top, AppSpacing.md + 8)
                    .padding(.leading, AppSpacing.md + 4)
            }

            TextEditor(text: $viewModel.reviewText)
                .font(AppTypography.body)
                .focused($isReviewTextFocused)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .padding(.vertical, AppSpacing.sm)
                .padding(.horizontal, AppSpacing.sm)
        }
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(isReviewTextFocused ? AppColor.primary : AppColor.primary.opacity(0.12), lineWidth: isReviewTextFocused ? 1.5 : 1)
        )
        .animation(.easeOut(duration: 0.15), value: isReviewTextFocused)
    }

    // MARK: - Photos

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                PhotosPicker(
                    selection: $photoPickerItems,
                    maxSelectionCount: 5,
                    matching: .images
                ) {
                    photoActionIcon(systemName: "photo.on.rectangle")
                }
                .disabled(!viewModel.canAddMorePhotos)
                .accessibilityLabel(localization.string(.chooseFromLibrary))

                Button {
                    guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
                    isShowingCamera = true
                } label: {
                    photoActionIcon(systemName: "camera")
                }
                .disabled(!viewModel.canAddMorePhotos)
                .accessibilityLabel(localization.string(.takePhoto))
                .accessibilityIdentifier("takePhotoButton")

                Spacer(minLength: 0)
            }

            if !viewModel.photos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(Array(viewModel.photos.enumerated()), id: \.offset) { index, data in
                            photoThumbnail(data: data, index: index)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        .shadow(color: AppColor.primaryDeep.opacity(0.06), radius: 10, x: 0, y: 4)
    }

    private func photoActionIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(AppColor.primary)
            .frame(width: 44, height: 44)
            .background(AppColor.surface)
            .clipShape(Circle())
    }

    private func photoThumbnail(data: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }

            Button {
                viewModel.removePhoto(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(.white, AppColor.textPrimary.opacity(0.7))
            }
            .accessibilityLabel(localization.string(.removePhoto))
            .offset(x: 6, y: -6)
        }
    }
}

#Preview {
    NavigationStack {
        RateProductView(
            viewModel: RateProductViewModel(
                product: Product(
                    id: "p-1", name: "Silk Wrap Midi Dress", price: Money(189.00), discountPrice: nil,
                    imageNames: [], categoryId: "dresses", variants: [],
                    description: "", averageRating: 4.7, reviewCount: 132
                ),
                reviewRepository: MockReviewRepository(),
                userSession: UserSession()
            )
        )
    }
    .environment(LocalizationManager())
}
