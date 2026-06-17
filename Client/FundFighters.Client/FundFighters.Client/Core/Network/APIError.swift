/*
===============================================================================
Проект: FundFighters (iOS UIKit Client)
Файл: APIError.swift
Расположение: FundFighters.Client/FundFighters.Client/Core/Network/
Назначение: Enum defining possible network API errors. //              Перечисление возможных ошибок сетевого API.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 04.02.2026
===============================================================================
*/

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(message: String)
    case unauthorized
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Invalid URL endpoint."
        case .requestFailed: return "Network request failed."
        case .decodingFailed: return "Failed to decode server response."
        case .serverError(let message):
            if message == "Failed to send verification code. Please try again." {
                return UserManager.shared.isRussian
                    ? "Не удалось отправить код подтверждения. Проверьте почту или попробуйте ещё раз через несколько секунд."
                    : "Failed to send the verification code. Check your email or try again in a few seconds."
            }
            return message
        case .unauthorized: return "Session expired. Please login again."
        case .unknown: return "An unknown error occurred."
        }
    }
}

struct APIErrorResponse: Decodable {
    let message: String
}
