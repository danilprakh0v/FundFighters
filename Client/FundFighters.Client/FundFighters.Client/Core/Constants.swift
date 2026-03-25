/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: Constants.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/
Назначение: Centralized constants for layout, fonts, and API configuration. //              Централизованные константы для верстки, шрифтов и конфигурации API.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import UIKit

// MARK: - App Constants / Константы Приложения
// Centralized place for all hardcoded values to avoid "Magic Numbers".
// Централизованное место для всех жестко заданных значений, чтобы избежать "Магических чисел".

struct Constants {
    
    // MARK: - Layout Metrics / Метрики Верстки
    struct Layout {
        /// Standard padding for edges (20.0)
        /// Стандартный отступ от краев (20.0)
        static let standardPadding: CGFloat = 20.0
        
        /// Small padding between elements (8.0)
        /// Маленький отступ между элементами (8.0)
        static let smallPadding: CGFloat = 8.0
        
        /// Medium padding (12.0)
        /// Средний отступ (12.0)
        static let mediumPadding: CGFloat = 12.0
        
        /// Large padding for section separation (30.0)
        /// Большой отступ для разделения секций (30.0)
        static let largePadding: CGFloat = 30.0
        
        /// Height for standard buttons (50.0)
        /// Высота для стандартных кнопок (50.0)
        static let buttonHeight: CGFloat = 50.0
        
        /// Corner radius for buttons and cards (12.0)
        /// Радиус скругления для кнопок и карточек (12.0)
        static let cornerRadius: CGFloat = 12.0
        
        /// Icon size for list items (40.0)
        /// Размер иконки для элементов списка (40.0)
        static let iconSize: CGFloat = 40.0
    }
    
    // MARK: - Font Sizes / Размеры Шрифтов
    struct Fonts {
        /// Large Title size (32.0)
        /// Размер большого заголовка (32.0)
        static let titleLarge: CGFloat = 32.0
        
        /// Header size (20.0)
        /// Размер заголовка (20.0)
        static let header: CGFloat = 20.0
        
        /// Body text size (16.0)
        /// Размер основного текста (16.0)
        static let body: CGFloat = 16.0
        
        /// Caption/Small text size (12.0)
        /// Размер подписи/маленького текста (12.0)
        static let caption: CGFloat = 12.0
    }
    
    // MARK: - Animation / Анимация
    struct Animation {
        /// Standard animation duration (0.3s)
        /// Стандартная длительность анимации (0.3с)
        static let duration: TimeInterval = 0.3
    }
    
    // MARK: - API Keys & Endpoints / API Ключи и Эндпоинты
    struct API {
        /// Placeholder for Auth Token Key in UserDefaults
        /// Ключ для хранения токена авторизации в UserDefaults
        static let authTokenKey = "auth_token"
    }
}
