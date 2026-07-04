//
//  SectionHeader.swift
//  alivium
//

import SwiftUI

/// Title + optional trailing "Show all" — the one place this pattern is implemented, reused
/// across every Home/Discover rail rather than rebuilt per section (CLAUDE.md 9.6).
struct SectionHeader: View {
    let title: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppTypography.headline)
                .foregroundStyle(AppColor.textPrimary)

            Spacer()

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.bodyEmphasis)
                        .foregroundStyle(AppColor.accent)
                }
            }
        }
    }
}

#Preview {
    SectionHeader(title: "Featured Products", actionTitle: "Show all") {}
        .padding()
}
