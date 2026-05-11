/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DashboardModels.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Models/
Назначение: Модели данных для главного экрана приложения (Dashboard).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import Foundation

// MARK: - Ответ Dashboard
// Основной контейнер данных для главного экрана.
struct DashboardResponse: Codable {
    let userInfo: UserInfoResponse
    let balanceInfo: BalanceInfoResponse
    let activeGoal: SavingsGoalResponse?
    let recentTransactions: [TransactionResponse]
    let recentBattles: [BattleResponse]
    let expenseCategories: [ExpenseCategoryResponse]
    
    enum CodingKeys: String, CodingKey {
        case userInfo
        case balanceInfo
        case activeGoal
        case recentTransactions
        case recentBattles
        case expenseCategories
    }
}

// MARK: - Информация о пользователе
struct UserInfoResponse: Codable {
    let username: String
    let email: String
}

// MARK: - Информация о балансе
struct BalanceInfoResponse: Codable {
    let totalBalance: Decimal
    let monthlyIncome: Decimal
    let incomeChangePercent: Decimal
    let monthlyExpense: Decimal
    let expenseChangePercent: Decimal
}

// MARK: - Сберегательная цель (Враг)
struct SavingsGoalResponse: Codable {
    let id: String
    let goalName: String
    let description: String
    let targetAmount: Decimal
    let currentAmount: Decimal
    let imageUrl: String
    let progressPercentage: Decimal
    let remainingAmount: Decimal
    let totalHearts: Int
    let defeatedHearts: Int
}

// MARK: - Транзакция
struct TransactionResponse: Codable {
    let id: String
    let amount: Decimal
    let type: String // "Income" или "Expense"
    let category: String
    let description: String
    let iconUrl: String
    let createdAt: Date
}

// MARK: - Битва
struct BattleResponse: Codable {
    let id: String
    let savingsGoalId: String
    let damageDealt: Decimal
    let xpGained: Int64
    let battleResult: String // "won" или "lost"
    let battleDate: Date
    let enemyName: String
    let enemyImageUrl: String
}

// MARK: - Категория расходов
struct ExpenseCategoryResponse: Codable {
    let id: String
    let name: String
    let colorHex: String
    let iconUrl: String
    let totalAmount: Decimal
    let percentage: Decimal
    let sortOrder: Int
}
