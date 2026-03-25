/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: RegisterViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/Register/
Назначение: ViewModel handling registration logic and state. //              ViewModel, обрабатывающая логику и состояние регистрации.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

// MARK: - Register ViewModel
// Responsible for handling user registration logic.
// Отвечает за логику регистрации пользователя.
final class RegisterViewModel {
    
    // MARK: - Properties / Свойства
    
    private let apiService = APIService.shared
    
    // Closures for UI binding / Замыкания для привязки UI
    var onRegisterSuccess: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Actions / Действия
    
    /// Attempts to register a new user.
    /// Пытается зарегистрировать нового пользователя.
    func register(username: String?, email: String?, password: String?) {
        // 1. Basic Validation / Базовая валидация
        guard let username = username, !username.isEmpty,
              let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            onError?("Please fill in all fields.\nПожалуйста, заполните все поля.")
            return
        }
        
        // 2. Start Loading / Начинаем загрузку
        onLoading?(true)
        
        let request = RegisterRequest(username: username, email: email, password: password)
        
        // 3. API Call / Вызов API
        apiService.register(request: request) { [weak self] (result: Result<Void, APIError>) in
            DispatchQueue.main.async {
                self?.onLoading?(false)
                
                switch result {
                case .success:
                    self?.onRegisterSuccess?()
                    
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
