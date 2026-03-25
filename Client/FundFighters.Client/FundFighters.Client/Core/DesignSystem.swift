/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DesignSystem.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/
Назначение: Централизованные токены дизайн-системы: цвета, шрифты, отступы.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

enum DS {

    // MARK: - Colors

    /// Основной фон экрана
    static let bg = UIColor.white

    /// Зелёный акцент — доходы, активные элементы
    static let accent = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1) // #10B981

    /// Красный акцент — расходы
    static let red = UIColor(red: 239/255, green: 68/255, blue: 68/255, alpha: 1) // #EF4444

    /// Основной текст (почти чёрный)
    static let textPrimary = UIColor(red: 26/255, green: 26/255, blue: 26/255, alpha: 1) // #1A1A1A

    /// Второстепенный текст (серый)
    static let textSecondary = UIColor(red: 107/255, green: 114/255, blue: 128/255, alpha: 1) // #6B7280

    /// Белый текст (поверх тёмных карточек)
    static let textWhite = UIColor.white

    /// Светло-серый фон лёгких элементов
    static let surfaceLight = UIColor(red: 243/255, green: 244/255, blue: 246/255, alpha: 1) // #F3F4F6

    // MARK: - Fonts

    /// GolosText-Bold
    static func golosBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "GolosText-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }

    /// GolosText-Medium
    static func golosMedium(_ size: CGFloat) -> UIFont {
        UIFont(name: "GolosText-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    /// GolosText-SemiBold
    static func golosSemi(_ size: CGFloat) -> UIFont {
        UIFont(name: "GolosText-SemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }

    /// GolosText-Regular
    static func golos(_ size: CGFloat) -> UIFont {
        UIFont(name: "GolosText-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    /// Inter-SemiBold
    static func interSemi(_ size: CGFloat) -> UIFont {
        UIFont(name: "Inter_18pt-SemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }

    /// Inter-Bold
    static func interBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Inter_18pt-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }

    /// Inter-Medium
    static func interMedium(_ size: CGFloat) -> UIFont {
        UIFont(name: "Inter_18pt-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    /// Inter-Light
    static func interLight(_ size: CGFloat) -> UIFont {
        UIFont(name: "Inter_18pt-Light", size: size) ?? .systemFont(ofSize: size, weight: .light)
    }

    /// Inter-ExtraBold
    static func interExtraBold(_ size: CGFloat) -> UIFont {
        UIFont(name: "Inter_18pt-ExtraBold", size: size) ?? .systemFont(ofSize: size, weight: .black)
    }

    /// Alias for SemiBold (Compatibility)
    static func inter(_ size: CGFloat) -> UIFont { interSemi(size) }

    // MARK: - Spacing

    static let screenPad: CGFloat = 20
    static let cardRadius: CGFloat = 20
    static let pillRadius: CGFloat = 10
}
