//
//  AppColor.swift
//  alivium
//

import SwiftUI

enum AppColor {
    static let primary = Color(hex: 0x334342)
    static let accent = Color(hex: 0xBB9264)

    // Supporting tints/shades derived from primary/accent, used for illustration depth.
    static let primaryDeep = Color(hex: 0x212B2A)
    static let primarySoft = Color(hex: 0x6E827E)
    static let accentDeep = Color(hex: 0x8F6B47)
    static let accentSoft = Color(hex: 0xE3C9A4)
    static let cream = Color(hex: 0xF7EFE4)

    static let background = Color(hex: 0xFFFFFF)
    static let backgroundOffWhite = Color(hex: 0xFAFAF8)
    static let surface = Color(hex: 0xF4F2EE)

    static let textPrimary = Color(hex: 0x1C1C1A)
    static let textSecondary = Color(hex: 0x8A8580)

    static let error = Color(hex: 0xC0392B)
}

extension Color {
    init(hex: UInt32) {
        let r = Double((hex >> 16) & 0xFF) / 255
        let g = Double((hex >> 8) & 0xFF) / 255
        let b = Double(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
