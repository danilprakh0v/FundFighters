/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: DashboardViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Dashboard/
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
    
    // MARK: - Properties
    
    private let apiService = APIService.shared
    
    // Published properties for UI binding
    @Published var dashboard: DashboardResponse?
    @Published var isLoading = false
    @Published var error: String?
    
    // Closures for UI updates
    var onDataLoaded: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    
    // MARK: - Methods
    
    /// Loads all dashboard data
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
                    
                case .failure(let error):
                    let errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
                    self?.setError(errorMessage)
                    self?.onError?(errorMessage)
                }
            }
        }
    }
    
    /// Refreshes dashboard data (pull-to-refresh)
    func refresh(completion: @escaping () -> Void) {
        loadDashboard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion()
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    // MARK: - Data Access
    
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
