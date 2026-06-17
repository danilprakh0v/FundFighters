/*
===============================================================================
Проект: FundFighters (iOS UIKit [Client/Backend Service])
Файл: APIService.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Core/Network/
Назначение: Сервисный слой для выполнения запросов к API
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

final class APIService {
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Авторизация
    
    // Вход пользователя
    func login(request: LoginRequest, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Регистрация нового пользователя
    func register(request: RegisterRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/register",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Подтверждение почты при регистрации
    func verifyEmail(request: VerifyCodeRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/verify",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Подтверждение входа (2FA или первый вход)
    func verifyLogin(request: VerifyCodeRequest, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/verify-login",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Запрос на сброс пароля
    func forgotPassword(request: ForgotPasswordRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/forgot-password",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Сброс пароля с использованием кода
    func resetPassword(request: ResetPasswordRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/reset-password",
            method: "POST",
            body: request,
            completion: completion
        )
    }

    func updateTwoFactor(enabled: Bool, completion: @escaping (Result<TwoFactorStatusResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/two-factor",
            method: "PUT",
            body: UpdateTwoFactorRequest(enabled: enabled),
            completion: completion
        )
    }

    func updateProfile(username: String, completion: @escaping (Result<ProfileResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/profile",
            method: "PUT",
            body: UpdateProfileRequest(username: username),
            completion: completion
        )
    }
    
    // MARK: - Главный экран (Dashboard)
    
    // Получить данные главного экрана
    func getDashboard(completion: @escaping (Result<DashboardResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/data",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // Получить информацию о балансе
    func getBalance(completion: @escaping (Result<BalanceInfoResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/balance",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // Получить активную цель сбережения
    func getActiveGoal(completion: @escaping (Result<SavingsGoalResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/active-goal",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // Получить недавние транзакции
    func getRecentTransactions(completion: @escaping (Result<[TransactionResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/recent-transactions",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // Получить недавние битвы
    func getRecentBattles(completion: @escaping (Result<[BattleResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/recent-battles",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // Получить категории расходов
    func getExpenseCategories(completion: @escaping (Result<[ExpenseCategoryResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/expense-categories",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    // MARK: - Игровые механики и транзакции
    
    // Обработать новую транзакцию
    func addTransaction(request: ProcessTransactionRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/game/transaction",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // Удалить транзакцию
    func deleteTransaction(transactionId: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/game/transaction/\(transactionId)",
            method: "DELETE",
            body: nil as String?,
            completion: completion
        )
    }
}
