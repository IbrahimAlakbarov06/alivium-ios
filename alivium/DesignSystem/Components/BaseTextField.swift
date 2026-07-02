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

    @State private var isSecureTextVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xs) {
                if style == .search {
                    Image(systemName: "magnifyingglass")
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
            .padding(.vertical, AppSpacing.sm)
            .padding(.horizontal, AppSpacing.md)
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(borderColor, lineWidth: 1)
            )

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
        return .clear
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
