//
//  Colors.swift
//  PrayerTimesWidget
//
//  Shared color theme for widget - Night Sky Theme
//

import SwiftUI

extension Color {
    // Hex color initializer for widgets
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // Sleep App Theme - Matching main app
    static let appBg         = Color(hex: "03174C")   // dark night sky blue
    static let cardBg        = Color(hex: "E8F0F8")   // light blue (cloud-like)
    static let cardBgDark    = Color(hex: "D0E0F0")   // darker card variant
    static let stroke        = Color(hex: "B8D0E8")   // light blue separator
    static let strokeLight   = Color(hex: "D0E0F0")   // lighter stroke
    static let textPrimary   = Color(hex: "1A2332")   // dark blue (high contrast)
    static let textPrimaryLight = Color(hex: "FFFFFF") // white (for dark backgrounds)
    static let textSecondary = Color(hex: "4A5A6A")   // medium blue-gray
    static let textSecondaryLight = Color(hex: "E0E8F0") // light blue-gray
    static let accentPurple  = Color(hex: "93A1ED")   // purple/lavender for buttons
    static let accentPurpleDark = Color(hex: "7A8AE0") // darker purple
    static let accentMoon    = Color(hex: "C5C6D0")   // gray moon
    static let accentMoonDark = Color(hex: "B0B1C0") // darker gray
    static let buttonText    = Color(hex: "F6F1FB")   // very light purple/white for button text
}

