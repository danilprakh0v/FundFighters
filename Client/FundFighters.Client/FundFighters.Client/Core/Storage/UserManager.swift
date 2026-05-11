/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: UserManager.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Storage/
Назначение: Глобальное состояние пользователя и управление сессией.
===============================================================================
*/

import Foundation

/// Легковесный менеджер для хранения данных текущего пользователя в оперативной памяти.
final class UserManager {
    static let shared = UserManager()
    
    struct UserSession {
        var username: String = "Fighter"
        var totalBalance: Double = 0.0
        var monthlyIncome: Double = 0.0
        var monthlyExpense: Double = 0.0
        
        // Данные активной цели
        var savingsGoalName: String = "No active goal"
        var savingsCurrent: Double = 0.0
        var savingsTarget: Double = 0.0
    }
    
    var session = UserSession()
    
    // Флаг для отображения туториала
    var hasSeenTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenTutorial") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenTutorial") }
    }
    
    private init() {}
    
    /// Очистка сессии при логауте
    func logout() {
        session = UserSession()
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial")
        TokenManager.shared.clear()
    }
}
