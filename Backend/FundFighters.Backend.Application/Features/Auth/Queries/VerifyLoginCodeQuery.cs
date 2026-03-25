/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: VerifyLoginCodeQuery.cs
Расположение: FundFighters.Backend.Application/Features/Auth/Queries/
Назначение: CQRS запрос для подтверждения кода двухфакторной аутентификации при входе.
            Проверяет код и завершает процесс входа.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Queries;

/// <summary>
/// CQRS запрос для подтверждения кода двухфакторной аутентификации.
/// Проверяет предоставленный код и завершает процесс входа.
/// 
/// CQRS query to verify two-factor authentication code.
/// Validates the provided code and completes the login process.
/// </summary>
public class VerifyLoginCodeQuery : IRequest<VerifyLoginCodeResponse>
{
    /// <summary>
    /// Email адрес игрока.
    /// The player's email address.
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Код двухфакторной аутентификации.
    /// The two-factor authentication code.
    /// </summary>
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Ответ после подтверждения кода двухфакторной аутентификации.
/// 
/// Response after verifying two-factor code.
/// </summary>
public class VerifyLoginCodeResponse
{
    /// <summary>
    /// Указывает, было ли подтверждение успешным.
    /// Indicates whether verification was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Сообщение с описанием результата.
    /// Message describing the result.
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID игрока (устанавливается если подтверждение успешно).
    /// The player's ID (set if verification succeeded).
    /// </summary>
    public int? PlayerId { get; set; }

    /// <summary>
    /// Имя пользователя игрока (устанавливается если подтверждение успешно).
    /// Player's username (set if verification succeeded).
    /// </summary>
    public string? Username { get; set; }

    /// <summary>
    /// JWT токен доступа (устанавливается если подтверждение успешно).
    /// JWT access token (set if verification succeeded).
    /// </summary>
    public string? Token { get; set; }
}