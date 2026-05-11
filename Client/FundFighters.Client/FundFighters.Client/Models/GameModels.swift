/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: GameModels.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Models/
Назначение: Модели данных для игровой логики и профиля пользователя.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

// MARK: - Профиль пользователя
struct UserProfile: Decodable {
    let id: UUID
    let username: String
    let email: String
    let firstName: String?
    let lastName: String?
    let balance: Double
    let level: Int
    let experience: Int
}

// MARK: - Состояние онбординга
struct OnboardingState: Codable {
    var isNewUser: Bool
    var completedSteps: [String]
}

// MARK: - Сводка Dashboard
struct DashboardSummary: Decodable {
    let currentBalance: Double
    let monthlyIncome: Double
    let monthlyExpenses: Double
    let recentTransactions: [Transaction]
}

struct Transaction: Decodable, Identifiable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: String
    let type: TransactionType
}

enum TransactionType: String, Decodable {
    case income
    case expense
}

// MARK: - Бюджетирование
struct BudgetCategory: Decodable, Identifiable {
    let id: UUID
    let name: String
    let iconName: String
    let limit: Double
    let spent: Double
}
