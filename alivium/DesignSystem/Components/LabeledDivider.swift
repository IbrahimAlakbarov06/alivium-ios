//
//  LabeledDivider.swift
//  alivium
//

import SwiftUI

/// A divider with centered label text, e.g. "or continue with" between a form and social
/// sign-in buttons. Lowercase reads softer/quieter than all-caps, matching the boutique tone.
struct LabeledDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            line
            Text(label)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)
                .fixedSize()
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(AppColor.primary.opacity(0.15))
            .frame(height: 1)
    }
}

#Preview {
    LabeledDivider(label: "or continue with")
        .padding()
}
