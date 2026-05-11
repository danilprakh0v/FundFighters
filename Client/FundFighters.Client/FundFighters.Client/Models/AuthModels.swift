/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: AuthModels.swift
Расположение: Client/FundFighters.Client/FundFighters.Client/Models/
Назначение: DTO для запросов и ответов аутентификации.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

// MARK: - Модели Аутентификации
// DTO для процессов входа, регистрации и восстановления доступа.

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterRequest: Encodable {
    let username: String
    let email: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String?
    let requiresTwoFactor: Bool?
    let username: String?
}

struct VerifyCodeRequest: Encodable {
    let email: String
    let code: String
}

struct ResendCodeRequest: Encodable {
    let email: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let code: String
    let newPassword: String
}

// MARK: - Модели Транзакций

struct ProcessTransactionRequest: Encodable {
    let amount: Decimal
    let type: Int // 0 - Расход, 1 - Сбережение
    let title: String
    let category: String
}
