/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: UserManager.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Storage/
Назначение: Глобальное состояние пользователя и управление сессией.
===============================================================================
*/

import Foundation
import UIKit

/// Легковесный менеджер для хранения данных текущего пользователя в оперативной памяти.
final class UserManager {
    static let shared = UserManager()

    struct SavingsEnemyGoal: Codable {
        let id: String
        var name: String
        var current: Double
        var target: Double
        var imageData: Data?
        var isDefault: Bool
    }
    
    struct UserSession {
        var username: String = "Fighter"
        var email: String = ""
        var userId: String = "37956481"
        var isTwoFactorEnabled: Bool = false
        var totalBalance: Double = 0.0
        var monthlyIncome: Double = 0.0
        var monthlyExpense: Double = 0.0
        
        // Данные активной цели
        var savingsGoalName: String = "PlayStation 5 Slim"
        var savingsCurrent: Double = 23250
        var savingsTarget: Double = 62000

        // Локально собранный враг для battle-scene core feature
        var customEnemyName: String = ""
    }
    
    var session = UserSession()
    private let goalsKey = "savingsEnemyGoals"
    private let activeGoalIndexKey = "activeSavingsEnemyGoalIndex"
    
    // Флаг языка
    var isRussian: Bool {
        get { UserDefaults.standard.bool(forKey: "isRussian") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "isRussian")
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
        }
    }
    
    // Флаг для отображения туториала
    var hasSeenTutorial: Bool {
        get { UserDefaults.standard.bool(forKey: "hasSeenTutorial") }
        set { UserDefaults.standard.set(newValue, forKey: "hasSeenTutorial") }
    }
    
    private init() {
        session.username = UserDefaults.standard.string(forKey: "username") ?? session.username
        session.email = UserDefaults.standard.string(forKey: "email") ?? session.email
        session.userId = UserDefaults.standard.string(forKey: "userId") ?? session.userId
        session.isTwoFactorEnabled = UserDefaults.standard.bool(forKey: "isTwoFactorEnabled")

        let savedTarget = UserDefaults.standard.double(forKey: "savingsTarget")
        if savedTarget > 0 {
            session.savingsCurrent = UserDefaults.standard.double(forKey: "savingsCurrent")
            session.savingsTarget = savedTarget
            session.savingsGoalName = UserDefaults.standard.string(forKey: "savingsGoalName") ?? session.savingsGoalName
        }
        session.customEnemyName = UserDefaults.standard.string(forKey: "customEnemyName") ?? ""
        syncSessionFromActiveGoal()
    }

    func saveSavingsGoal(current: Double, target: Double, name: String) {
        session.savingsCurrent = current
        session.savingsTarget = target
        session.savingsGoalName = name
        UserDefaults.standard.set(current, forKey: "savingsCurrent")
        UserDefaults.standard.set(target, forKey: "savingsTarget")
        UserDefaults.standard.set(name, forKey: "savingsGoalName")
        updateActiveGoal(current: current, target: target, name: name)
    }

    func saveProfile(username: String, email: String? = nil, userId: String? = nil) {
        session.username = username
        UserDefaults.standard.set(username, forKey: "username")

        if let email {
            session.email = email
            UserDefaults.standard.set(email, forKey: "email")
        }

        if let userId {
            session.userId = userId
            UserDefaults.standard.set(userId, forKey: "userId")
        }
    }

    func saveTwoFactorEnabled(_ enabled: Bool) {
        session.isTwoFactorEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "isTwoFactorEnabled")
    }

    func saveAvatarData(_ data: Data) {
        UserDefaults.standard.set(data, forKey: "avatarData")
        NotificationCenter.default.post(name: NSNotification.Name("AvatarChanged"), object: nil)
    }

    func avatarData() -> Data? {
        UserDefaults.standard.data(forKey: "avatarData")
    }

    func saveCustomEnemy(name: String, imageData: Data, current: Double = 0, target: Double? = nil) {
        session.customEnemyName = name
        session.savingsGoalName = name
        let finalTarget = max(1000, target ?? session.savingsTarget)
        let goal = SavingsEnemyGoal(
            id: UUID().uuidString,
            name: name,
            current: current,
            target: finalTarget,
            imageData: imageData,
            isDefault: false
        )
        var goals = enemyGoals()
        goals.append(goal)
        saveEnemyGoals(goals)
        setActiveGoal(index: goals.count - 1)
        UserDefaults.standard.set(name, forKey: "customEnemyName")
        UserDefaults.standard.set(imageData, forKey: "customEnemyImageData")
        UserDefaults.standard.set(name, forKey: "savingsGoalName")
        NotificationCenter.default.post(name: NSNotification.Name("EnemyChanged"), object: nil)
    }

    func customEnemyImageData() -> Data? {
        UserDefaults.standard.data(forKey: "customEnemyImageData")
    }

    func customEnemyImage() -> UIImage? {
        guard let data = activeEnemyGoal().imageData ?? customEnemyImageData() else { return nil }
        return UIImage(data: data)
    }

    func enemyGoals() -> [SavingsEnemyGoal] {
        let fallback = SavingsEnemyGoal(
            id: "playstation-default",
            name: "PlayStation 5 Slim",
            current: 23250,
            target: 62000,
            imageData: nil,
            isDefault: true
        )
        guard let data = UserDefaults.standard.data(forKey: goalsKey),
              let decoded = try? JSONDecoder().decode([SavingsEnemyGoal].self, from: data),
              !decoded.isEmpty else {
            return [fallback]
        }
        if decoded.contains(where: { $0.isDefault }) { return decoded }
        return [fallback] + decoded
    }

    func activeEnemyGoal() -> SavingsEnemyGoal {
        let goals = enemyGoals()
        let index = min(max(0, UserDefaults.standard.integer(forKey: activeGoalIndexKey)), goals.count - 1)
        return goals[index]
    }

    func setActiveGoal(index: Int) {
        let goals = enemyGoals()
        guard !goals.isEmpty else { return }
        let safeIndex = min(max(0, index), goals.count - 1)
        UserDefaults.standard.set(safeIndex, forKey: activeGoalIndexKey)
        let goal = goals[safeIndex]
        session.savingsGoalName = goal.name
        session.savingsCurrent = goal.current
        session.savingsTarget = goal.target
        session.customEnemyName = goal.isDefault ? "" : goal.name
        UserDefaults.standard.set(goal.name, forKey: "savingsGoalName")
        UserDefaults.standard.set(goal.current, forKey: "savingsCurrent")
        UserDefaults.standard.set(goal.target, forKey: "savingsTarget")
        NotificationCenter.default.post(name: NSNotification.Name("EnemyChanged"), object: nil)
    }

    func switchEnemyGoal(delta: Int) {
        let goals = enemyGoals()
        guard !goals.isEmpty else { return }
        let current = min(max(0, UserDefaults.standard.integer(forKey: activeGoalIndexKey)), goals.count - 1)
        let next = (current + delta + goals.count) % goals.count
        setActiveGoal(index: next)
    }

    @discardableResult
    func deleteActiveEnemyGoal() -> Bool {
        var goals = enemyGoals()
        let index = min(max(0, UserDefaults.standard.integer(forKey: activeGoalIndexKey)), goals.count - 1)
        guard goals.indices.contains(index), !goals[index].isDefault else { return false }
        goals.remove(at: index)
        saveEnemyGoals(goals)
        setActiveGoal(index: min(index, goals.count - 1))
        return true
    }

    private func updateActiveGoal(current: Double, target: Double, name: String) {
        var goals = enemyGoals()
        let index = min(max(0, UserDefaults.standard.integer(forKey: activeGoalIndexKey)), goals.count - 1)
        guard goals.indices.contains(index) else { return }
        goals[index].current = current
        goals[index].target = target
        goals[index].name = name
        saveEnemyGoals(goals)
    }

    private func saveEnemyGoals(_ goals: [SavingsEnemyGoal]) {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }

    private func syncSessionFromActiveGoal() {
        let goal = activeEnemyGoal()
        session.savingsGoalName = goal.name
        session.savingsCurrent = goal.current
        session.savingsTarget = goal.target
        session.customEnemyName = goal.isDefault ? "" : goal.name
    }
    
    /// Reload in-memory session values from UserDefaults.
    /// Call this after a successful login so username/avatar persists across logout cycles.
    func reloadFromStorage() {
        session.username = UserDefaults.standard.string(forKey: "username") ?? "Fighter"
        session.email = UserDefaults.standard.string(forKey: "email") ?? ""
        session.userId = UserDefaults.standard.string(forKey: "userId") ?? session.userId
        session.isTwoFactorEnabled = UserDefaults.standard.bool(forKey: "isTwoFactorEnabled")
        session.customEnemyName = UserDefaults.standard.string(forKey: "customEnemyName") ?? ""
        syncSessionFromActiveGoal()
    }

    /// Очистка сессии при логауте
    func logout() {
        session = UserSession()
        // Reload persisted personal data (username, avatar) immediately so
        // they're available in the next session without a full app restart.
        session.username = UserDefaults.standard.string(forKey: "username") ?? "Fighter"
        session.email = UserDefaults.standard.string(forKey: "email") ?? ""
        UserDefaults.standard.removeObject(forKey: "savingsCurrent")
        UserDefaults.standard.removeObject(forKey: "savingsTarget")
        UserDefaults.standard.removeObject(forKey: "savingsGoalName")
        UserDefaults.standard.removeObject(forKey: "customEnemyName")
        UserDefaults.standard.removeObject(forKey: "customEnemyImageData")
        UserDefaults.standard.removeObject(forKey: goalsKey)
        UserDefaults.standard.removeObject(forKey: activeGoalIndexKey)
        // Note: "username", "email", "avatarData" are intentionally kept
        // so they survive logout/re-login cycles.
        UserDefaults.standard.removeObject(forKey: "isTwoFactorEnabled")
        UserDefaults.standard.removeObject(forKey: "hasSeenTutorial")
        TokenManager.shared.clear()
    }
}
