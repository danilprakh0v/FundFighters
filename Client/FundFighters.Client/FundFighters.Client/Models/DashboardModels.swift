/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DashboardModels.swift
Расположение: FundFighters.Client/FundFighters.Client/Models/
Назначение: Модели для главного экрана (Dashboard).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import Foundation

// MARK: - Main Dashboard Response
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

// MARK: - User Info
struct UserInfoResponse: Codable {
    let username: String
    let email: String
}

// MARK: - Balance Info
struct BalanceInfoResponse: Codable {
    let totalBalance: Decimal
    let monthlyIncome: Decimal
    let incomeChangePercent: Decimal
    let monthlyExpense: Decimal
    let expenseChangePercent: Decimal
}

// MARK: - Savings Goal (Enemy)
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

// MARK: - Transaction
struct TransactionResponse: Codable {
    let id: String
    let amount: Decimal
    let type: String // "Income" or "Expense"
    let category: String
    let description: String
    let iconUrl: String
    let createdAt: Date
}

// MARK: - Battle
struct BattleResponse: Codable {
    let id: String
    let savingsGoalId: String
    let damageDealt: Decimal
    let xpGained: Int64
    let battleResult: String // "won" or "lost"
    let battleDate: Date
    let enemyName: String
    let enemyImageUrl: String
}

// MARK: - Expense Category
struct ExpenseCategoryResponse: Codable {
    let id: String
    let name: String
    let colorHex: String
    let iconUrl: String
    let totalAmount: Decimal
    let percentage: Decimal
    let sortOrder: Int
}
