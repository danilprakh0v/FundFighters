/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: VerifyEmailCommand.cs
Расположение: FundFighters.Backend.Application/Features/Auth/Commands/
Назначение: CQRS команда для верификации email адреса игрока.
            Проверяет корректность кода подтверждения и активирует учетную запись.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Commands;

/// <summary>
/// CQRS команда для верификации email адреса игрока с использованием кода.
/// Проверяет подлинность кода подтверждения и активирует учетную запись.
/// Возвращает JWT токен для последующей аутентификации.
/// 
/// CQRS command to verify player's email address using verification code.
/// Validates code authenticity and activates the account.
/// Returns JWT token for subsequent authentication.
/// </summary>
public class VerifyEmailCommand : IRequest<VerifyEmailResponse>
{
    /// <summary>
    /// Email адрес игрока для верификации.
    /// The player's email address.
    /// </summary>
    public string Email { get; set; } = string.Empty;

    /// <summary>
    /// Код верификации, полученный по почте.
    /// The verification code received via email.
    /// </summary>
    public string Code { get; set; } = string.Empty;
}

/// <summary>
/// Ответ после попытки верификации email адреса.
/// 
/// Response after email verification attempt.
/// </summary>
public class VerifyEmailResponse
{
    /// <summary>
    /// Указывает, была ли верификация успешной.
    /// Indicates whether verification was successful.
    /// </summary>
    public bool Success { get; set; }

    /// <summary>
    /// Сообщение с описанием результата (успех или ошибка).
    /// Message describing the result.
    /// </summary>
    public string Message { get; set; } = string.Empty;

    /// <summary>
    /// ID игрока (устанавливается если верификация успешна).
    /// The player's ID (set if verification succeeded).
    /// </summary>
    public int? PlayerId { get; set; }
}
