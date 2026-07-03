//
//  OTPCodeField.swift
//  alivium
//

import SwiftUI

/// Reusable one-time-code input: `length` individually boxed cells (rounded, beige fill,
/// matching `BaseTextField`'s surface/border style) that auto-advance focus to the next box as
/// each digit is typed, and move focus back to the previous box when a box is cleared. Not
/// hardcoded to 6 digits or to the Verification Code screen — any digit-count OTP flow can
/// reuse this.
struct OTPCodeField: View {
    @Binding var code: String
    let length: Int

    @State private var digits: [String]
    // Bumped only when a keystroke gets rejected (see `binding(for:)`) — forces that one cell's
    // TextField to a fresh identity so its underlying UIKit text buffer re-syncs to `digits`.
    // A SwiftUI TextField doesn't reliably revert its displayed text just because the binding's
    // setter transformed the value to something other than what was typed (a well-known
    // TextField/Binding sync gap): without this, a rejected non-digit character (e.g. from a
    // hardware keyboard, paste, or autofill) can visibly linger in the box even though `digits`
    // — the actual source of truth used for verification — correctly discarded it.
    @State private var rejectionTokens: [Int]
    @FocusState private var focusedIndex: Int?

    init(code: Binding<String>, length: Int = 6) {
        self._code = code
        self.length = length
        // Sized correctly up front — `ForEach` below builds all `length` cells on the very
        // first render, and each cell reads `digits[index]` immediately, so this can't start
        // out empty (that was an index-out-of-range crash waiting to happen).
        let chars = Array(code.wrappedValue.prefix(length)).map { String($0) }
        self._digits = State(initialValue: chars + Array(repeating: "", count: max(0, length - chars.count)))
        self._rejectionTokens = State(initialValue: Array(repeating: 0, count: length))
    }

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<length, id: \.self) { index in
                cell(at: index)
            }
        }
        .onChange(of: code) { _, newValue in
            if newValue != digits.joined() {
                syncDigitsFromCode()
            }
        }
    }

    private func cell(at index: Int) -> some View {
        TextField("", text: binding(for: index))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(AppTypography.title)
            .foregroundStyle(AppColor.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(borderColor(for: index), lineWidth: borderWidth(for: index))
            )
            .focused($focusedIndex, equals: index)
            .animation(.easeOut(duration: 0.15), value: focusedIndex)
            .accessibilityIdentifier("otpCell\(index)")
            .id("otp-\(index)-\(rejectionTokens[index])")
            .onChange(of: digits[index]) { oldValue, newValue in
                handleDigitChange(at: index, oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: rejectionTokens[index]) { _, _ in
                // The .id() bump above forces this TextField to a fresh UIKit-backed instance
                // (see `rejectionTokens`' doc comment) — but that recreation can drop keyboard
                // focus, and `focusedIndex` is already `index` here, so simply re-assigning the
                // same value is a no-op the focus system won't act on. Force a genuine nil ->
                // index transition instead, so it actually reclaims first responder on the new
                // instance. This is a rare, low-frequency path (only on rejected input, not
                // every keystroke), unlike the per-keystroke advance logic that previously ruled
                // out DispatchQueue for exactly this reason.
                focusedIndex = nil
                DispatchQueue.main.async {
                    focusedIndex = index
                }
            }
    }

    private func binding(for index: Int) -> Binding<String> {
        Binding(
            get: { index < digits.count ? digits[index] : "" },
            set: { newValue in
                guard index < digits.count else { return }
                let filtered = newValue.filter(\.isNumber)
                if filtered.count != newValue.count {
                    rejectionTokens[index] += 1
                }
                // The field can hand back more than one character if a digit was typed over an
                // already-filled box — the newest keystroke is what belongs in this cell. Note:
                // this setter does nothing else — no focus change, no `code` sync — precisely
                // because mutating `@FocusState` from inside a TextField's own binding setter
                // (still mid-callback for that keystroke) previously caused real re-entrancy
                // bugs: first a hang under fast input, then a focus/data race once that hang was
                // "fixed" with a raw `DispatchQueue.main.async`. `onChange` below is the safe,
                // SwiftUI-sanctioned place to react to this with more state changes.
                digits[index] = filtered.isEmpty ? "" : String(filtered.last!)
            }
        )
    }

    private func handleDigitChange(at index: Int, oldValue: String, newValue: String) {
        code = digits.joined()

        // Only auto-advance if this cell was the one actually being edited — guards against
        // `syncDigitsFromCode()` (an external `code` reset, e.g. a resend clearing it) mutating
        // `digits` in bulk and yanking focus around as a side effect.
        guard focusedIndex == index else { return }

        if newValue.isEmpty {
            if index > 0 {
                focusedIndex = index - 1
            }
        } else {
            focusedIndex = index < length - 1 ? index + 1 : nil
        }
    }

    private func syncDigitsFromCode() {
        let chars = Array(code.prefix(length)).map { String($0) }
        digits = chars + Array(repeating: "", count: max(0, length - chars.count))
    }

    private func borderColor(for index: Int) -> Color {
        focusedIndex == index ? AppColor.primary : AppColor.primary.opacity(0.12)
    }

    private func borderWidth(for index: Int) -> CGFloat {
        focusedIndex == index ? 1.5 : 1
    }
}

#Preview {
    VStack(spacing: AppSpacing.xl) {
        OTPCodeField(code: .constant(""))
        OTPCodeField(code: .constant("42"))
        OTPCodeField(code: .constant("1234"), length: 4)
    }
    .padding()
    .background(AppColor.background)
}
