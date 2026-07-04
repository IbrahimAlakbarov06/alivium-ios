//
//  CategoryBanner.swift
//  alivium
//

import SwiftUI

/// Full-width, color-tinted category block for Discover's top-level browse section — a photo
/// bleeds flush to one edge, a bold uppercase label sits in the tinted portion on the other.
/// Distinct shape from `CollectionCard` (which is a full-bleed photo with a bottom gradient
/// overlay), so it isn't reused here despite the visual similarity in spirit.
struct CategoryBanner: View {
    let title: String
    let imageName: String
    let tint: Color
    var imageLeading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                if imageLeading { image }

                Text(title.uppercased())
                    .font(.system(size: 21, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: imageLeading ? .trailing : .leading)
                    .padding(.horizontal, AppSpacing.lg)

                if !imageLeading { image }
            }
            .frame(height: 116)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private var image: some View {
        CatalogImage(name: imageName)
            .frame(width: 130)
            .clipped()
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        CategoryBanner(title: "Clothing", imageName: "Onboarding1", tint: AppColor.primary, imageLeading: false) {}
        CategoryBanner(title: "Shoes", imageName: "Onboarding2", tint: AppColor.accent, imageLeading: true) {}
    }
    .padding()
}
