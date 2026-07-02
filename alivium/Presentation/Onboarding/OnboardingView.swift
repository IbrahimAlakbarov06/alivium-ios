//
//  OnboardingView.swift
//  alivium
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage: Int = 0

    private let pages = OnboardingContent.pages

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                VStack(spacing: AppSpacing.lg) {
                    PageIndicator(numberOfPages: pages.count, currentPage: currentPage)

                    BaseButton(
                        title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                        kind: .primary
                    ) {
                        advance()
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.bottom, AppSpacing.xl)
            }

            if currentPage < pages.count - 1 {
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            onComplete()
                        }
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(Color(hex: 0x334342).opacity(0.75))
                        .padding(.trailing, AppSpacing.md)
                        .padding(.top, AppSpacing.xxs)
                    }
                    Spacer()
                }
            }
        }
    }

    private func advance() {
        if currentPage == pages.count - 1 {
            onComplete()
        } else {
            withAnimation(.easeInOut(duration: 0.4)) {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
