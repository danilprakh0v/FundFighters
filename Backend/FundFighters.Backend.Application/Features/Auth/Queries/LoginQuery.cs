/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: LoginQuery.cs
Расположение: FundFighters.Backend.Application/Features/Auth/Queries/
Назначение: CQRS запрос для аутентификации игрока и получения JWT токена.
            Проверяет учетные данные и возвращает токен для авторизации.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Queries;

/// <summary>
/// CQRS запрос для аутентификации игрока и получения JWT токена доступа.
/// Проверяет email и пароль, затем возвращает JWT для последующих запросов.
/// Требует, чтобы email был ранее верифицирован.
/// 
/// CQRS query to authenticate a player and retrieve JWT token.
/// Validates credentials and returns JWT token for subsequent requests.
/// Requires email to be previously verified.
/// </summary>
public class LoginQuery : IRequest<LoginResponse>
{
    /// <summary>
    /// Email адрес игрока для аутентификации.
    /// The player's email address.
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Пароль игрока (открытый текст, будет проверен против хеша).
    /// The player's password (plaintext, will be verified against hash).
    /// </summary>
    public string Password { get; set; } = string.Empty;
}

/// <summary>
/// Ответ после попытки входа в систему.
/// 
/// Response after login attempt.
/// </summary>
public class LoginResponse
{
    /// <summary>
    /// Указывает, был ли логин успешным.
    /// Indicates whether login was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Сообщение с описанием результата (успех или ошибка).
    /// Message describing the result.
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID игрока (устанавливается если логин успешен).
    /// The player's ID (set if login succeeded).
    /// </summary>
    public int? PlayerId { get; set; }

    /// <summary>
    /// Указывает, требуется ли двухфакторная аутентификация.
    /// Indicates whether two-factor authentication is required.
    /// </summary>
    public bool RequiresTwoFactor { get; set; } = false;

    /// <summary>
    /// JWT токен доступа (устанавливается если логин успешен и 2FA не требуется).
    /// JWT access token (set if login succeeded and 2FA is not required).
    /// </summary>
    public string? Token { get; set; }

    /// <summary>
    /// Имя пользователя игрока (устанавливается если логин успешен).
    /// Player's username (set if login succeeded).
    /// </summary>
    public string? Username { get; set; }

    /// <summary>
    /// Email игрока.
    /// </summary>
    public string? Email { get; set; }

    /// <summary>
    /// Текущее состояние двухфакторной аутентификации.
    /// </summary>
    public bool IsTwoFactorEnabled { get; set; }
}
