//
//  InteractiveRatingView.swift
//  alivium
//

import SwiftUI

/// A tappable 1-5 star input — distinct from `RatingView` (read-only display, takes a `Double`
/// for half-star aggregate averages). This always deals in whole stars, since a shopper can only
/// ever pick a whole rating, and gives the tapped star a light bounce for a bit of delight.
struct InteractiveRatingView: View {
    @Binding var rating: Int
    var starSize: CGFloat = 36

    @State private var bouncingStar: Int?

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: starSize, weight: .medium))
                    .foregroundStyle(AppColor.accent)
                    .scaleEffect(bouncingStar == star ? 1.3 : 1.0)
                    .onTapGesture { select(star) }
                    .accessibilityIdentifier("ratingStar-\(star)")
            }
        }
    }

    private func select(_ star: Int) {
        rating = star
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) {
            bouncingStar = star
        }
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                bouncingStar = nil
            }
        }
    }
}

#Preview {
    @Previewable @State var rating = 3
    return InteractiveRatingView(rating: $rating)
        .padding()
}
