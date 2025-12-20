import SwiftUI

extension Color {
    // Sleep App Theme - Dark night sky with purple accents and light blue cards
    
    // Backgrounds
    static let appBg         = Color(hex: "03174C")   // dark night sky blue (deep, rich)
    static let cardBg        = Color(hex: "E8F0F8")   // light blue (cloud-like cards)
    static let cardBgDark    = Color(hex: "D0E0F0")   // slightly darker card variant for depth
    
    // Borders & Separators
    static let stroke        = Color(hex: "B8D0E8")   // light blue separator (visible contrast)
    static let strokeLight   = Color(hex: "D0E0F0")   // lighter stroke for subtle dividers
    
    // Text Colors - High contrast for readability
    static let textPrimary   = Color(hex: "1A2332")   // dark blue (strong contrast on light cards)
    static let textPrimaryLight = Color(hex: "FFFFFF") // white (for dark backgrounds)
    static let textSecondary = Color(hex: "4A5A6A")   // medium blue-gray (softer but clear)
    static let textSecondaryLight = Color(hex: "E0E8F0") // light blue-gray (for dark backgrounds)
    
    // Accents
    static let accentPurple  = Color(hex: "93A1ED")   // purple/lavender for buttons and selected items
    static let accentPurpleDark = Color(hex: "7A8AE0") // darker purple for pressed states
    static let accentMoon    = Color(hex: "C5C6D0")   // gray moon (for moon/star elements)
    static let accentMoonDark = Color(hex: "B0B1C0") // darker gray for pressed states
    static let accentGold    = Color(hex: "F5C371")   // golden yellow for preferred/highlighted items
    
    // Button Text
    static let buttonText    = Color(hex: "F6F1FB")   // very light purple/white for button text
    
    // Tab Bar
    static let tabBg         = Color(hex: "052A5F")   // slightly lighter than appBg
    static let tabSelected   = Color(hex: "93A1ED")   // purple (matching button theme)
    static let tabUnselected = Color(hex: "FFFFFF")   // white for clear contrast
    static let tabBorder     = Color(hex: "1A3A6A")   // subtle border
}


extension Color {
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
