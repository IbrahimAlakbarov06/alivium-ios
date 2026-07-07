//
//  BaseTextField.swift
//  alivium
//

import SwiftUI

enum AppTextFieldStyleKind {
    case standard
    case search
    case secure
}

struct BaseTextField: View {
    let placeholder: String
    @Binding var text: String
    var style: AppTextFieldStyleKind = .standard
    var keyboardType: UIKeyboardType? = nil
    var autocapitalization: TextInputAutocapitalization? = nil
    var disablesAutocorrection: Bool? = nil
    var errorMessage: String? = nil
    /// A fixed, non-editable label shown before the field's own text (e.g. "+994" ahead of a
    /// phone number) — `text` only ever holds what the shopper types after it.
    var prefix: String? = nil

    @State private var isSecureTextVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xs) {
                if style == .search {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppColor.textSecondary)
                }

                if let prefix {
                    Text(prefix)
                        .font(AppTypography.body)
                        .foregroundStyle(AppColor.textSecondary)
                }

                fieldContent
                    .font(AppTypography.body)
                    .keyboardType(keyboardType ?? .default)
                    .focused($isFocused)

                if style == .secure {
                    Button {
                        isSecureTextVisible.toggle()
                    } label: {
                        Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                            .foregroundStyle(AppColor.textSecondary)
                    }
                }
            }
            .padding(.vertical, AppSpacing.md)
            .padding(.horizontal, AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .animation(.easeOut(duration: 0.15), value: isFocused)

            if let errorMessage {
                Text(errorMessage)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.error)
            }
        }
    }

    @ViewBuilder
    private var fieldContent: some View {
        if style == .secure && !isSecureTextVisible {
            SecureField(placeholder, text: $text)
        } else {
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(resolvedAutocapitalization)
                .autocorrectionDisabled(disablesAutocorrection ?? (style == .search))
        }
    }

    private var resolvedAutocapitalization: TextInputAutocapitalization {
        autocapitalization ?? (style == .search ? .never : .sentences)
    }

    private var borderColor: Color {
        if errorMessage != nil { return AppColor.error }
        if isFocused { return AppColor.primary }
        return AppColor.primary.opacity(0.12)
    }

    private var borderWidth: CGFloat {
        (isFocused || errorMessage != nil) ? 1.5 : 1
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        BaseTextField(placeholder: "Email", text: .constant(""))
        BaseTextField(placeholder: "Search products", text: .constant(""), style: .search)
        BaseTextField(placeholder: "Password", text: .constant(""), style: .secure)
        BaseTextField(placeholder: "Email", text: .constant("bad"), errorMessage: "Enter a valid email address")
    }
    .padding()
    .background(AppColor.background)
}
