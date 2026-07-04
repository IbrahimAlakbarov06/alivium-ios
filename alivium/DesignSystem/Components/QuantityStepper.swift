//
//  QuantityStepper.swift
//  alivium
//

import SwiftUI

/// Small +/- control for adjusting a cart line item's quantity — one implementation, not
/// rebuilt per screen (CLAUDE.md 9.6).
struct QuantityStepper: View {
    @Binding var quantity: Int
    var minimum: Int = 1
    var maximum: Int = 99

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            stepButton(icon: "minus", isEnabled: quantity > minimum, identifier: "quantityStepperDecrement") {
                quantity = max(minimum, quantity - 1)
            }

            Text("\(quantity)")
                .font(AppTypography.bodyEmphasis)
                .foregroundStyle(AppColor.textPrimary)
                .frame(minWidth: 20)

            stepButton(icon: "plus", isEnabled: quantity < maximum, identifier: "quantityStepperIncrement") {
                quantity = min(maximum, quantity + 1)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs)
        .background(AppColor.surface)
        .clipShape(Capsule())
    }

    private func stepButton(icon: String, isEnabled: Bool, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isEnabled ? AppColor.textPrimary : AppColor.textSecondary.opacity(0.4))
                .frame(width: 22, height: 22)
        }
        .disabled(!isEnabled)
        .accessibilityIdentifier(identifier)
    }
}

#Preview {
    QuantityStepper(quantity: .constant(2))
        .padding()
}
