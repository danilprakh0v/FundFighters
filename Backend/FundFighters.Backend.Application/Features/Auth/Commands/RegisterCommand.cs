/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: RegisterCommand.cs
Расположение: FundFighters.Backend.Application/Features/Auth/Commands/
Назначение: CQRS команда для регистрации нового игрока в системе.
            Инициирует процесс создания учетной записи с валидацией данных.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Commands;

/// <summary>
/// CQRS команда для регистрации новой учетной записи игрока.
/// Содержит данные пользователя и инициирует обработку регистрации.
/// Валидация выполняется на уровне handler'а.
/// 
/// CQRS command to register a new player account.
/// Contains user data and initiates registration processing.
/// Validation is performed at handler level.
/// </summary>
public class RegisterCommand : IRequest<RegisterResponse>
{
    /// <summary>
    /// Желаемое имя пользователя (nickname) для отображения в приложении.
    /// Player's desired username.
    /// </summary>
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// Email адрес игрока для верификации через письмо.
    /// Player's email address for verification.
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Пароль игрока (будет захеширован с использованием BCrypt).
    /// Player's password (will be hashed).
    /// </summary>
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Ответ после успешной регистрации.
/// 
/// Response after successful registration.
/// </summary>
public class RegisterResponse
{
    /// <summary>
    /// Указывает, была ли регистрация успешной.
    /// Indicates whether registration was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Сообщение с описанием результата (успех или ошибка).
    /// Message describing the result.
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID нового игрока (null если регистрация не удалась).
    /// The player's ID (null if registration failed).
    /// </summary>
    public int? PlayerId { get; set; }
}
