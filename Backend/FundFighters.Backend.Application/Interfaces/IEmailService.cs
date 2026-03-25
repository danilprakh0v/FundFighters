/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: IEmailService.cs
Расположение: FundFighters.Backend.Application/Interfaces/
Назначение: Интерфейс сервиса электронной почты для отправки писем верификации.
            Абстрагирует реализацию отправки писем от слоя приложения.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Application.Interfaces;

/// <summary>
/// Интерфейс сервиса электронной почты для отправки писем верификации и уведомлений.
/// Абстрагирует логику отправки писем от слоя приложения, обеспечивая слабую связанность.
/// Реализация может быть любой (SMTP, SendGrid, AWS SES и т.д.).
/// 
/// Interface for email service implementation.
/// Abstracts the email sending logic from the application layer.
/// Implementation can be SMTP, SendGrid, AWS SES, etc.
/// </summary>
public interface IEmailService
{
    /// <summary>
    /// Sends an email verification code to the specified email address.
    /// </summary>
    /// <param name="email">The recipient's email address.</param>
    /// <param name="code">The verification code to send.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    Task SendVerificationCodeAsync(string email, string code);

    /// <summary>
    /// Sends a login verification code to the specified email address for 2FA.
    /// </summary>
    /// <param name="email">The recipient's email address.</param>
    /// <param name="code">The login verification code to send.</param>
    /// <returns>A task representing the asynchronous operation.</returns>
    Task SendLoginVerificationCodeAsync(string email, string code);

    /// <summary>
    /// Sends a general email (e.g. for password reset).
    /// </summary>
    Task SendEmailAsync(string email, string subject, string body);
    string GenerateResetPasswordHtmlTemplate(string code);
}

