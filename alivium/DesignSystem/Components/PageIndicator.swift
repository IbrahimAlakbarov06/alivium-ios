//
//  PageIndicator.swift
//  alivium
//

import SwiftUI

struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? AppColor.accent : AppColor.textSecondary.opacity(0.3))
                    .frame(width: index == currentPage ? 22 : 7, height: 7)
                    // Flattens each dot into a single opaque layer before the spring-driven
                    // width animation runs, so the translucent fill can't pick up a transient
                    // top/bottom shading from being blended mid-transition.
                    .compositingGroup()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
    }
}

#Preview {
    PageIndicator(numberOfPages: 3, currentPage: 1)
        .padding()
}
