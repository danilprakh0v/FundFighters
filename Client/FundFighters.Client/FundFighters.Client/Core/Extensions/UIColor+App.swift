/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: UIColor+App.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Extensions/
Назначение: Custom color palette extension using hex codes. //              Расширение с кастомной палитрой цветов через hex-коды.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - App Colors
// Extension to manage a consistent color palette across the app.
// We use static variables for easy access: UIColor.appBackground
extension UIColor {
    
    // Main Background (Dark Grey)
    // Used for the main screen background.
    static let appBackground = UIColor(hex: "#1E1E1E")
    
    // Secondary Background (Lighter Grey)
    // Used for cards, cells, and panels.
    static let appSecondary = UIColor(hex: "#2C2C2C")
    
    // Accent Green (Success/Income)
    // Used for "Saving" buttons, income transactions, and positive stats.
    static let appGreen = UIColor(hex: "#27AE60")
    
    // Accent Red (Expense/Damage)
    // Used for "Expense" buttons, negative transactions, and enemy damage.
    static let appRed = UIColor(hex: "#E74C3C")
    
    // Text White
    // Main text color for readability on dark background.
    static let appWhite = UIColor(hex: "#FFFFFF")
    
    // Text Grey
    // Secondary text color for subtitles and details.
    static let appGrey = UIColor(hex: "#A0A0A0")
    
    // Helper init for Hex strings
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
