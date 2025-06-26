import SwiftUI

struct ThemeColors {
    // 主题相关颜色
    static var background: Color {
        Color(.systemBackground)
    }
    
    static var secondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var tertiaryBackground: Color {
        Color(.tertiarySystemBackground)
    }
    
    static var label: Color {
        Color(.label)
    }
    
    static var secondaryLabel: Color {
        Color(.secondaryLabel)
    }
    
    // 节假日相关颜色
    static var holidayRed: Color {
        Color("HolidayRed")
    }
    
    static var holidayBlue: Color {
        Color("HolidayBlue")
    }
    
    static var holidayOrange: Color {
        Color("HolidayOrange")
    }
    
    static var holidayPurple: Color {
        Color("HolidayPurple")
    }
    
    // 交互相关颜色
    static var selectionBlue: Color {
        Color.blue.opacity(0.3)
    }
    
    static var selectionBackground: Color {
        Color(.systemGray6)
    }
    
    // 阴影颜色
    static var shadow: Color {
        Color.black.opacity(0.05)
    }
}

// 扩展 Color 以支持主题颜色
extension Color {
    static var themeBackground: Color {
        ThemeColors.background
    }
    
    static var themeSecondaryBackground: Color {
        ThemeColors.secondaryBackground
    }
    
    static var themeTertiaryBackground: Color {
        ThemeColors.tertiaryBackground
    }
    
    static var themeLabel: Color {
        ThemeColors.label
    }
    
    static var themeSecondaryLabel: Color {
        ThemeColors.secondaryLabel
    }
    
    static var themeHolidayRed: Color {
        ThemeColors.holidayRed
    }
    
    static var themeHolidayBlue: Color {
        ThemeColors.holidayBlue
    }
    
    static var themeHolidayOrange: Color {
        ThemeColors.holidayOrange
    }
    
    static var themeHolidayPurple: Color {
        ThemeColors.holidayPurple
    }
    
    static var themeSelectionBlue: Color {
        ThemeColors.selectionBlue
    }
    
    static var themeSelectionBackground: Color {
        ThemeColors.selectionBackground
    }
    
    static var themeShadow: Color {
        ThemeColors.shadow
    }
    
    // 添加十六进制颜色初始化器
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
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