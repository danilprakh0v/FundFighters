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
    let email: String?
    let userId: String?
    let isTwoFactorEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case token
        case requiresTwoFactor
        case username
        case email
        case userId
        case playerId
        case isTwoFactorEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        requiresTwoFactor = try container.decodeIfPresent(Bool.self, forKey: .requiresTwoFactor)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        isTwoFactorEnabled = try container.decodeIfPresent(Bool.self, forKey: .isTwoFactorEnabled)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
            ?? container.decodeIfPresent(Int.self, forKey: .playerId).map(String.init)
    }
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

struct UpdateTwoFactorRequest: Encodable {
    let enabled: Bool
}

struct TwoFactorStatusResponse: Decodable {
    let isTwoFactorEnabled: Bool
}

struct UpdateProfileRequest: Encodable {
    let username: String
}

struct ProfileResponse: Decodable {
    let username: String
    let email: String?
    let userId: String?
    let playerId: Int?
    let isTwoFactorEnabled: Bool?
}

// MARK: - Модели Транзакций

struct ProcessTransactionRequest: Encodable {
    let amount: Decimal
    let type: Int // 0 - Расход, 1 - Сбережение
    let title: String
    let category: String
    let date: String?
}
