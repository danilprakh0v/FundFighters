/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: TokenManager.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Storage/
Назначение: Manages secure storage of authentication tokens. //              Управляет безопасным хранением токенов аутентификации.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private let key = "auth_token"
    
    private init() {}
    
    func save(_ token: String) {
        UserDefaults.standard.set(token, forKey: key)
    }
    
    func get() -> String? {
        // FOR MOCK/TESTING PURPOSES ONLY:
        // Uncomment the line below to hardcode a token if you want to skip Login screen for now.
        // return "YOUR_TEST_JWT_TOKEN" 
        return UserDefaults.standard.string(forKey: key)
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    var hasToken: Bool {
        return get() != nil
    }
}
