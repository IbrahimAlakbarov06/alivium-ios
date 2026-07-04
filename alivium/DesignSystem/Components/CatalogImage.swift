//
//  CatalogImage.swift
//  alivium
//

import SwiftUI
import UIKit

/// Loads a named asset from Assets.xcassets; falls back to a neutral placeholder when the
/// asset doesn't exist yet. Phase 1 sample data ships with the image *names* products/banners/
/// collections will use before the real photography has been added — this lets Home be built
/// and wired now, and the moment a matching asset is dropped into Assets.xcassets, it starts
/// rendering automatically with no code change.
struct CatalogImage: View {
    let name: String?

    var body: some View {
        if let name, UIImage(named: name) != nil {
            Image(name)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                AppColor.surface
                Image(systemName: "photo")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(AppColor.textSecondary.opacity(0.4))
            }
        }
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        CatalogImage(name: nil)
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
        CatalogImage(name: "DoesNotExistYet")
            .frame(width: 140, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
    }
    .padding()
}
