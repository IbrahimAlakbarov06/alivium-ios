//
//  OnboardingPageView.swift
//  alivium
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPageContent

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let progress = width == 0 ? 0 : proxy.frame(in: .global).minX / width
            let illustrationHeight = height * 0.64

            VStack(spacing: 0) {
                photoBlock(width: width, height: illustrationHeight, progress: progress)

                ZStack(alignment: .top) {
                    LinearGradient(
                        colors: [page.backgroundTint, AppColor.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    textBlock(progress: progress)
                        .padding(.top, AppSpacing.xl)
                }
                .frame(height: height - illustrationHeight)
            }
            .frame(width: width, height: height)
        }
    }

    private func photoBlock(width: CGFloat, height: CGFloat, progress: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            illustration

            LinearGradient(
                colors: [page.backgroundTint, page.backgroundTint.opacity(0)],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: height * 0.38)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.xl))
        .offset(x: progress * -28)
        .scaleEffect(1 - min(abs(progress) * 0.12, 0.12), anchor: .top)
        .opacity(1 - min(abs(progress) * 0.7, 0.7))
    }

    private func textBlock(progress: CGFloat) -> some View {
        VStack(spacing: AppSpacing.sm) {
            Text(page.kicker)
                .font(AppTypography.caption)
                .fontWeight(.semibold)
                .tracking(2)
                .foregroundStyle(AppColor.accent)

            Text(page.title)
                .font(AppTypography.display)
                .tracking(-0.4)
                .foregroundStyle(AppColor.textPrimary)
                .multilineTextAlignment(.center)

            Text(page.subtitle)
                .font(AppTypography.body)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .offset(x: progress * 50)
        .opacity(1 - min(abs(progress) * 0.9, 0.9))
    }

    @ViewBuilder
    private var illustration: some View {
        switch page.id {
        case 0:
            OnboardingIllustration1()
        case 1:
            OnboardingIllustration2()
        default:
            OnboardingIllustration3()
        }
    }
}

#Preview {
    OnboardingPageView(page: OnboardingContent.pages[0])
}
