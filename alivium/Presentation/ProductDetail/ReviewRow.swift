//
//  ReviewRow.swift
//  alivium
//

import SwiftUI

struct ReviewRow: View {
    let review: Review

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            initialAvatar

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Text(review.reviewerName)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.textPrimary)

                    Spacer()

                    Text(Self.dateFormatter.string(from: review.date))
                        .font(AppTypography.caption)
                        .foregroundStyle(AppColor.textSecondary)
                }

                RatingView(rating: Double(review.rating), starSize: 11)

                Text(review.text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.top, 2)
            }
        }
    }

    private var initialAvatar: some View {
        ZStack {
            Circle().fill(AppColor.primary)
            Text(review.reviewerName.first.map(String.init) ?? "?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(width: 36, height: 36)
    }
}

#Preview {
    ReviewRow(review: Review(
        id: "1", reviewerName: "Aysel M.", rating: 5,
        text: "The fabric feels so much more expensive than the price.",
        date: .now
    ))
    .padding()
}
