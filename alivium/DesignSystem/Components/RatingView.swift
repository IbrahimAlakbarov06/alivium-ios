//
//  RatingView.swift
//  alivium
//

import SwiftUI

/// Star + average + review count (e.g. "4.6 (128 reviews)") — Product Detail's summary line and
/// each individual `Review` row share this so star styling never drifts between the two.
struct RatingView: View {
    let rating: Double
    /// When provided, renders "(count reviews)" after the average; omit for a single review's
    /// own star row (just the stars, no aggregate count).
    var reviewCount: Int? = nil
    var starSize: CGFloat = 13

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: starImageName(for: index))
                        .font(.system(size: starSize, weight: .medium))
                        .foregroundStyle(AppColor.accent)
                }
            }

            if reviewCount != nil {
                Text(String(format: "%.1f", rating))
                    .font(AppTypography.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)
            }

            if let reviewCount {
                Text("(\(reviewCount))")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }

    private func starImageName(for index: Int) -> String {
        let threshold = Double(index) + 1
        if rating >= threshold { return "star.fill" }
        if rating >= threshold - 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

#Preview {
    VStack(alignment: .leading, spacing: AppSpacing.md) {
        RatingView(rating: 4.6, reviewCount: 128)
        RatingView(rating: 5, reviewCount: nil, starSize: 11)
    }
    .padding()
}
