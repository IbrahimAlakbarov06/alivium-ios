//
//  HomeSkeletonView.swift
//  alivium
//

import SwiftUI

/// Loading-state placeholder mirroring Home's real section shapes, so the first paint doesn't
/// jump/reflow once content loads — shimmering rectangles rather than a spinner (CLAUDE.md 9.8).
struct HomeSkeletonView: View {
    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            block(height: 420, cornerRadius: AppRadius.lg)
                .padding(.horizontal, AppSpacing.md)

            HStack(spacing: AppSpacing.xs) {
                ForEach(0..<4, id: \.self) { _ in
                    block(width: 80, height: 36, cornerRadius: AppRadius.pill)
                }
            }
            .padding(.horizontal, AppSpacing.md)

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                block(width: 160, height: 20, cornerRadius: AppRadius.sm)
                HStack(spacing: AppSpacing.md) {
                    ForEach(0..<2, id: \.self) { _ in
                        block(width: 158, height: 220, cornerRadius: AppRadius.md)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
        .padding(.top, AppSpacing.lg)
    }

    private func block(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(AppColor.surface)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .shimmering()
    }
}

#Preview {
    HomeSkeletonView()
}
