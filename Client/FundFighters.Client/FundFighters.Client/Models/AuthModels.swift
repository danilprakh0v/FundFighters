/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: AuthModels.swift
Расположение: FundFighters.Client/FundFighters.Client/Models/
Назначение: DTOs for Authentication requests and responses. //              DTO для запросов и ответов аутентификации.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

// MARK: - Auth Models
// DTOs for Authentication (Login, Register).

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
