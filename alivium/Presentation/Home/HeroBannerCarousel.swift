//
//  HeroBannerCarousel.swift
//  alivium
//

import SwiftUI

/// Home's hero carousel — one large, edge-to-edge editorial image per slide with a bottom
/// gradient scrim for text legibility (the same vignette technique `OnboardingPageView` already
/// uses, so Home doesn't invent a new visual language for hero imagery). Deliberately the very
/// first thing below the top bar — the one moment on this screen meant to feel like a
/// photograph, not a UI, before any navigational chrome (category chips) appears.
struct HeroBannerCarousel: View {
    let banners: [HeroBanner]
    var onTapBanner: (HeroBanner) -> Void = { _ in }

    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            TabView(selection: $currentIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    slide(for: banner)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .aspectRatio(4.0 / 5.0, contentMode: .fit)

            if banners.count > 1 {
                PageIndicator(numberOfPages: banners.count, currentPage: currentIndex)
            }
        }
    }

    private func slide(for banner: HeroBanner) -> some View {
        Button {
            onTapBanner(banner)
        } label: {
            ZStack(alignment: .bottomLeading) {
                CatalogImage(name: banner.imageName)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(banner.kicker)
                        .font(AppTypography.caption)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundStyle(AppColor.accentSoft)

                    Text(banner.title)
                        .font(AppTypography.display)
                        .foregroundStyle(.white)

                    Text(banner.ctaTitle)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(.white)
                        .underline(true, color: AppColor.accent)
                        .padding(.top, AppSpacing.xxs)
                }
                .padding(AppSpacing.lg)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HeroBannerCarousel(banners: [
        HeroBanner(id: "1", imageName: "Hero1", kicker: "NEW SEASON", title: "The Autumn Edit", ctaTitle: "Shop the Edit"),
        HeroBanner(id: "2", imageName: "Hero2", kicker: "LIMITED DROP", title: "Evening, Elevated", ctaTitle: "Discover More")
    ])
}
