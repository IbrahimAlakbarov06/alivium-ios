//
//  LabeledDivider.swift
//  alivium
//

import SwiftUI

/// A divider with centered label text, e.g. "OR CONTINUE WITH" between a form and social
/// sign-in buttons.
struct LabeledDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Rectangle()
                .fill(AppColor.textSecondary.opacity(0.2))
                .frame(height: 1)

            Text(label.uppercased())
                .font(AppTypography.caption)
                .tracking(1)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize()

            Rectangle()
                .fill(AppColor.textSecondary.opacity(0.2))
                .frame(height: 1)
        }
    }
}

#Preview {
    LabeledDivider(label: "or continue with")
        .padding()
}
