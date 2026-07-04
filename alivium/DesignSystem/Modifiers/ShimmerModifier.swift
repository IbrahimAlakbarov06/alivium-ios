//
//  ShimmerModifier.swift
//  alivium
//

import SwiftUI

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, AppColor.background.opacity(0.6), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 400)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 2
                }
            }
    }
}

extension View {
    /// A moving highlight sweep over the view — used for loading-state skeleton placeholders
    /// instead of a spinner, for a calmer, more premium feel (CLAUDE.md 9.8).
    func shimmering() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    RoundedRectangle(cornerRadius: AppRadius.md)
        .fill(AppColor.surface)
        .frame(width: 200, height: 120)
        .shimmering()
        .padding()
}
