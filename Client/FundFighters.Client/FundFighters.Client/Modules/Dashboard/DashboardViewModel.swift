/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DashboardViewModel.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Modules/Dashboard/
Назначение: ViewModel для главного экрана (Dashboard). Управляет состоянием, загрузкой данных и взаимодействием с API.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

import Foundation
import Combine

// MARK: - Dashboard ViewModel
final class DashboardViewModel: ObservableObject {
    
    // MARK: - Свойства
    
    private let apiService = APIService.shared
    
    // Свойства для привязки к UI
    @Published var dashboard: DashboardResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    // Замыкания для обновления UI
    var onDataLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    // MARK: - Методы
    
    /// Загрузка всех данных для дашборда
    func loadDashboard() {
        setLoading(true)
        clearError()
        
        apiService.getDashboard { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success(let dashboard):
                    self?.dashboard = dashboard
                    self?.onDataLoaded?()
                    
                case .failure:
                    // Резервные данные для демонстрации при отсутствии подключения к серверу
                    self?.dashboard = DashboardResponse(
                        userInfo: UserInfoResponse(username: "danilis bobi", email: "daniils.95@yandex.ru"),
                        balanceInfo: BalanceInfoResponse(
                            totalBalance: 145000.99,
                            monthlyIncome: 100000,
                            incomeChangePercent: 27,
                            monthlyExpense: 45000,
                            expenseChangePercent: 12
                        ),
                        activeGoal: SavingsGoalResponse(
                            id: "1",
                            goalName: "Playstation 5 Slim",
                            description: "Победите врага, чтобы получить консоль!",
                            targetAmount: 62000,
                            currentAmount: 23250,
                            imageUrl: "ps5_monster",
                            progressPercentage: 37.5,
                            remainingAmount: 38750,
                            totalHearts: 8,
                            defeatedHearts: 3
                        ),
                        recentTransactions: [
                            TransactionResponse(id: "1", amount: 400, type: "Expense", category: "Подписка", description: "Яндекс Плюс", iconUrl: "yandex_icon", createdAt: Date()),
                            TransactionResponse(id: "2", amount: 700, type: "Expense", category: "Подписка", description: "Spotify Premium", iconUrl: "spotify_icon", createdAt: Date().addingTimeInterval(-3600 * 5)),
                            TransactionResponse(id: "3", amount: 300, type: "Income", category: "Перевод", description: "Зарплата UI/UX дизайнера", iconUrl: "salary_icon", createdAt: Date().addingTimeInterval(-3600 * 10))
                        ],
                        recentBattles: [],
                        expenseCategories: []
                    )
                    self?.onDataLoaded?()
                }
            }
        }
    }
    
    /// Обновление данных дашборда (pull-to-refresh)
    func refresh(completion: @escaping () -> Void) {
        loadDashboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    // MARK: - Вспомогательные методы
    
    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
        onLoadingStateChanged?(isLoading)
    }
    
    private func setError(_ errorMessage: String) {
        self.error = errorMessage
    }
    
    private func clearError() {
        self.error = nil
    }
    
    // MARK: - Доступ к данным
    
    var userInfo: UserInfoResponse? {
        dashboard?.userInfo
    }
    
    var balanceInfo: BalanceInfoResponse? {
        dashboard?.balanceInfo
    }
    
    var activeGoal: SavingsGoalResponse? {
        dashboard?.activeGoal
    }
    
    var recentTransactions: [TransactionResponse] {
        dashboard?.recentTransactions ?? []
    }
    
    var recentBattles: [BattleResponse] {
        dashboard?.recentBattles ?? []
    }
    
    var expenseCategories: [ExpenseCategoryResponse] {
        dashboard?.expenseCategories ?? []
    }
}
