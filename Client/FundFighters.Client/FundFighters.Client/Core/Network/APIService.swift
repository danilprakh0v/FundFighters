/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: APIService.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Network/
Назначение: Service layer for making specific API calls (Game, Auth). //              Сервисный слой для выполнения конкретных вызовов API (Игра, Авторизация).
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
    
    // MARK: - Auth
    
    /// Login user / Вход пользователя
    func login(request: LoginRequest, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    /// Register new user / Регистрация нового пользователя
    func register(request: RegisterRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/register",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    /// Verify email during registration / Подтверждение почты при регистрации
    func verifyEmail(request: VerifyCodeRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/verify",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    /// Verify login (2FA or first-time login) / Подтверждение входа
    func verifyLogin(request: VerifyCodeRequest, completion: @escaping (Result<LoginResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/auth/verify-login",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    /// Request password reset / Запрос на сброс пароля
    func forgotPassword(request: ForgotPasswordRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/forgot-password",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    /// Reset password with code / Сброс пароля с использованием кода
    func resetPassword(request: ResetPasswordRequest, completion: @escaping (Result<Void, APIError>) -> Void) {
        NetworkManager.shared.requestNoResponse(
            endpoint: "/auth/reset-password",
            method: "POST",
            body: request,
            completion: completion
        )
    }
    
    // MARK: - Dashboard
    
    /// Get dashboard data / Получить данные главного экрана
    func getDashboard(completion: @escaping (Result<DashboardResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/data",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    /// Get balance info / Получить информацию о балансе
    func getBalance(completion: @escaping (Result<BalanceInfoResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/balance",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    /// Get active savings goal / Получить активную цель сбережения
    func getActiveGoal(completion: @escaping (Result<SavingsGoalResponse, APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/active-goal",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    /// Get recent transactions / Получить недавние транзакции
    func getRecentTransactions(completion: @escaping (Result<[TransactionResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/recent-transactions",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    /// Get recent battles / Получить недавние битвы
    func getRecentBattles(completion: @escaping (Result<[BattleResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/recent-battles",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
    
    /// Get expense categories / Получить категории расходов
    func getExpenseCategories(completion: @escaping (Result<[ExpenseCategoryResponse], APIError>) -> Void) {
        NetworkManager.shared.request(
            endpoint: "/dashboard/expense-categories",
            method: "GET",
            body: nil as String?,
            completion: completion
        )
    }
}

