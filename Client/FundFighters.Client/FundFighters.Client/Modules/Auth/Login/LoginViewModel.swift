/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: LoginViewModel.swift
Расположение: FundFighters.Client/FundFighters.Client/Modules/Auth/Login/
Назначение: ViewModel handling login logic and state. //              ViewModel, обрабатывающая логику и состояние входа.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

// MARK: - Login ViewModel
// Responsible for handling user authentication logic.
// Отвечает за логику аутентификации пользователя.
final class LoginViewModel {
    
    // MARK: - Properties / Свойства
    
    private let apiService = APIService.shared
    
    // Closures for UI binding / Замыкания для привязки UI
    var onLoginSuccess: (() -> Void)?
    var onVerificationRequired: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    // MARK: - Actions / Действия
    
    /// Attempts to log the user in.
    /// Пытается выполнить вход пользователя.
    /// - Parameters:
    ///   - email: User's email / Email пользователя
    ///   - password: User's password / Пароль пользователя
    func login(email: String?, password: String?) {
        // 1. Basic Validation / Базовая валидация
        guard let email = email, !email.isEmpty,
              let password = password, !password.isEmpty else {
            onError?("Please enter both email and password.\nПожалуйста, введите email и пароль.")
            return
        }
        
        // 2. Start Loading / Начинаем загрузку
        onLoading?(true)
        
        let request = LoginRequest(email: email, password: password)
        
        // 3. API Call / Вызов API
        apiService.login(request: request) { [weak self] (result: Result<LoginResponse, APIError>) in
            // Stop loading on main thread / Останавливаем загрузку на главном потоке
            DispatchQueue.main.async {
                self?.onLoading?(false)
            }
            
            switch result {
            case .success(let response):
                // 4. Save Token + Username / Сохраняем токен и имя
                if let token = response.token {
                    TokenManager.shared.save(token)
                    // Server username is the source of truth after login.
                    let serverUsername = response.username ?? ""
                    UserManager.shared.saveProfile(
                        username: serverUsername.isEmpty ? "Fighter" : serverUsername,
                        email: response.email,
                        userId: response.userId
                    )
                    if let isTwoFactorEnabled = response.isTwoFactorEnabled {
                        UserManager.shared.saveTwoFactorEnabled(isTwoFactorEnabled)
                    }
                    // Navigate to Dashboard / Переход на главный экран
                    DispatchQueue.main.async {
                        self?.onLoginSuccess?()
                    }
                } else if response.requiresTwoFactor == true {
                    DispatchQueue.main.async {
                        self?.onVerificationRequired?()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.onError?("Login failed: No token received.\nВход не удался: Токен не получен.")
                    }
                }
                
            case .failure(let error):
                // Handle Error / Обработка ошибки
                DispatchQueue.main.async {
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    /// Initiates forgot password flow.
    func forgotPassword(email: String?) {
        guard let email = email, !email.isEmpty else {
            onError?("Please enter your email address.")
            return
        }
        
        onLoading?(true)
        let request = ForgotPasswordRequest(email: email)
        apiService.forgotPassword(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.onLoading?(false)
                switch result {
                case .success:
                    self?.onVerificationRequired?() // Reuse for now or add specific callback
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
}
