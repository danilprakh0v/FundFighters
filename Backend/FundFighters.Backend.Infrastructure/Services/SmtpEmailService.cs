/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: SmtpEmailService.cs
Расположение: FundFighters.Backend.Infrastructure/Services/
Назначение: Реализация сервиса отправки email через протокол SMTP.
              Обеспечивает формирование и рассылку HTML-писем с использованием MailKit.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
===============================================================================
*/

using FundFighters.Backend.Application.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using System;
using System.Threading.Tasks;

namespace FundFighters.Backend.Infrastructure.Services;

/// <summary>
/// Сервис отправки электронной почты с использованием MailKit. 
/// Шаблон полностью адаптирован под дизайн iOS UIKit приложения FundFighters.
/// </summary>
public class SmtpEmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<SmtpEmailService> _logger;

    private const string LogoUrl = "https://raw.githubusercontent.com/danilprakh0v/FundFighters-misc/main/Logo_FF.png";

    public SmtpEmailService(IConfiguration configuration, ILogger<SmtpEmailService> logger)
    {
        _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task SendLoginVerificationCodeAsync(string email, string code)
    {
        var body = GenerateLoginHtmlEmailTemplate(code);
        await SendEmailAsync(email, "FundFighters — подтверждение входа", body);
    }
    
    public async Task SendVerificationCodeAsync(string email, string code)
    {
        var body = GenerateHtmlEmailTemplate(code);
        await SendEmailAsync(email, "FundFighters — подтверждение email", body);
    }

    public async Task SendEmailAsync(string email, string subject, string body)
    {
        try
        {
            var smtpSettings = _configuration.GetSection("SmtpSettings");
            var server = smtpSettings["Server"];
            var port = int.Parse(smtpSettings["Port"] ?? "587");
            var senderEmail = smtpSettings["SenderEmail"];
            var appPassword = smtpSettings["AppPassword"];
            var senderName = smtpSettings["SenderName"] ?? "FundFighters";

            if (string.IsNullOrEmpty(server) || string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(appPassword))
            {
                _logger.LogError("SMTP settings not configured properly");
                throw new InvalidOperationException("SMTP configuration is missing");
            }

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(senderName, senderEmail));
            message.To.Add(new MailboxAddress("", email));
            message.Subject = subject;

            var bodyBuilder = new BodyBuilder { HtmlBody = body };
            message.Body = bodyBuilder.ToMessageBody();

            using (var client = new SmtpClient())
            {
                await client.ConnectAsync(server, port, SecureSocketOptions.StartTls);
                await client.AuthenticateAsync(senderEmail, appPassword);
                await client.SendAsync(message);
                await client.DisconnectAsync(true);
            }

            _logger.LogInformation($"Email '{subject}' successfully sent to {email}");
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error sending email to {email}: {ex.Message}");
            throw;
        }
    }

    private string GenerateLoginHtmlEmailTemplate(string code)
    {
        const string accentGreen = "#1E8C62";
        const string lightGreenBg = "#F0F9F5";
        const string securityBg = "#F4F7F6";
        const string textDark = "#000000";
        const string textMuted = "#555555";
        const string footerLinkColor = "#0056D2";

        var logoHtml = $@"<div style='width: 100%; text-align: center; margin-bottom: 24px;'>
            <center>
                <img src='{LogoUrl}' alt='FundFighters Logo' width='200' style='width: 200px; height: auto; border: 0; outline: none; text-decoration: none; display: inline-block; pointer-events: none; user-select: none;' />
            </center>
         </div>";

        return $@"<!DOCTYPE html>
<html lang='ru'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap' rel='stylesheet'>
    <style>
        body {{ font-family: 'Inter', -apple-system, sans-serif; background-color: #F4F4F4; margin: 0; padding: 0; }}
        .email-wrapper {{ background-color: #F4F4F4; padding: 40px 16px; }}
        .email-container {{ max-width: 540px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; }}
        .header {{ background-color: {lightGreenBg}; padding: 48px 36px; text-align: center; border-bottom: 2px solid {accentGreen}; }}
        .brand-name {{ font-size: 32px; font-weight: 900; color: {textDark}; margin-bottom: 8px; }}
        .brand-tagline {{ font-size: 11px; font-weight: 700; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1px; }}
        .body {{ padding: 44px 36px; }}
        .title {{ font-size: 22px; font-weight: 800; color: {textDark}; margin-bottom: 20px; }}
        .text {{ font-size: 15px; color: {textMuted}; line-height: 1.7; margin-bottom: 12px; }}
        .verification-box {{ background-color: {lightGreenBg}; border: 2px solid {accentGreen}; border-radius: 12px; padding: 36px 24px; text-align: center; margin: 32px 0; }}
        .verification-code {{ font-size: 48px; font-weight: 700; color: {accentGreen}; letter-spacing: 8px; font-family: 'Inter', sans-serif; }}
        .security-box {{ background-color: {securityBg}; border-left: 4px solid {accentGreen}; border-radius: 8px; padding: 20px; margin-bottom: 28px; }}
        .security-title {{ font-size: 11px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; margin-bottom: 12px; display: block; }}
        .security-text {{ font-size: 14px; color: {textDark}; line-height: 1.6; }}
        .security-text strong {{ font-weight: 700; }}
        .footer {{ padding: 32px; text-align: center; background-color: #F4F4F4; }}
        .footer-link {{ color: {footerLinkColor}; text-decoration: none; font-weight: 600; font-size: 13px; }}
        .footer-divider {{ color: #CCCCCC; margin: 0 8px; }}
    </style>
</head>
<body>
    <div class='email-wrapper'>
        <div class='email-container'>
            <div class='header'>
                {logoHtml}
                <div class='brand-name'>FundFighters</div>
                <div class='brand-tagline'>Управление Бюджетом</div>
            </div>
            <div class='body'>
                <h2 class='title'>Подтверждение входа в аккаунт</h2>
                <p class='text'>Мы заметили попытку входа в ваш аккаунт <strong style='color: {accentGreen};'>FundFighters</strong> с нового устройства.</p>
                <p class='text'>Для безопасности, пожалуйста, подтвердите вход используя код ниже.</p>

                <div class='verification-box'>
                    <span style='font-size: 16px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1.2px; margin-bottom: 16px; display: block;'>
                        Ваш код подтверждения входа
                    </span>
                    <div class='verification-code'>{code}</div>
                </div>

                <div class='security-box'>
                    <span class='security-title'>Безопасность</span>
                    <div class='security-text'>
                        <div style='margin-bottom: 8px;color: {textMuted}; '><strong>Никогда не делитесь этим кодом.</strong></div>
                        <div style='margin-bottom: 4px; color: {textMuted};'>Срок действия: <strong>10 минут</strong>.</div>
                        <div style='color: {textMuted};'>Код действует <strong>только один раз</strong>.</div>
                    </div>
                </div>

                <p class='text' style='font-size: 13px; margin-top: 24px;'>
                    Если это не вы пытались войти, немедленно измените пароль в настройках аккаунта.<br>Ваш аккаунт останется в безопасности без подтверждения кода.
                </p>
            </div>
        </div>
        <div class='footer'>
            <a href='#' class='footer-link'>Политика конфиденциальности</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Условия</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Поддержка</a>
            <div style='font-size: 11px; color: {accentGreen}; margin-top: 16px;'>© 2026 FundFighters Inc. Все права защищены.</div>
        </div>
    </div>
</body>
</html>";
    }

    private string GenerateHtmlEmailTemplate(string code)
    {
        const string accentGreen = "#1E8C62";
        const string lightGreenBg = "#F0F9F5";
        const string securityBg = "#F4F7F6";
        const string textDark = "#000000";
        const string textMuted = "#555555";
        const string footerLinkColor = "#0056D2";

        var logoHtml = $@"<div style='width: 100%; text-align: center; margin-bottom: 24px;'>
            <center>
                <img src='{LogoUrl}' alt='FundFighters Logo' width='200' style='width: 200px; height: auto; border: 0; outline: none; text-decoration: none; display: inline-block; pointer-events: none; user-select: none;' />
            </center>
         </div>";

        return $@"<!DOCTYPE html>
<html lang='ru'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap' rel='stylesheet'>
    <style>
        body {{ font-family: 'Inter', -apple-system, sans-serif; background-color: #F4F4F4; margin: 0; padding: 0; }}
        .email-wrapper {{ background-color: #F4F4F4; padding: 40px 16px; }}
        .email-container {{ max-width: 540px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; }}
        .header {{ background-color: {lightGreenBg}; padding: 48px 36px; text-align: center; border-bottom: 2px solid {accentGreen}; }}
        .brand-name {{ font-size: 32px; font-weight: 900; color: {textDark}; margin-bottom: 8px; }}
        .brand-tagline {{ font-size: 11px; font-weight: 700; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1px; }}
        .body {{ padding: 44px 36px; }}
        .title {{ font-size: 22px; font-weight: 800; color: {textDark}; margin-bottom: 20px; }}
        .text {{ font-size: 15px; color: {textMuted}; line-height: 1.7; margin-bottom: 12px; }}
        .verification-box {{ background-color: {lightGreenBg}; border: 2px solid {accentGreen}; border-radius: 12px; padding: 36px 24px; text-align: center; margin: 32px 0; }}
        .verification-code {{ font-size: 48px; font-weight: 700; color: {accentGreen}; letter-spacing: 8px; font-family: 'Inter', sans-serif; }}
        .security-box {{ background-color: {securityBg}; border-left: 4px solid {accentGreen}; border-radius: 8px; padding: 20px; margin-bottom: 28px; }}
        .security-title {{ font-size: 11px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; margin-bottom: 12px; display: block; }}
        .security-text {{ font-size: 14px; color: {textDark}; line-height: 1.6; }}
        .security-text strong {{ font-weight: 700; }}
        .footer {{ padding: 32px; text-align: center; background-color: #F4F4F4; }}
        .footer-link {{ color: {footerLinkColor}; text-decoration: none; font-weight: 600; font-size: 13px; }}
        .footer-divider {{ color: #CCCCCC; margin: 0 8px; }}
    </style>
</head>
<body>
    <div class='email-wrapper'>
        <div class='email-container'>
            <div class='header'>
                {logoHtml}
                <div class='brand-name'>FundFighters</div>
                <div class='brand-tagline'>Управление Бюджетом</div>
            </div>
            <div class='body'>
                <h2 class='title'>Подтверждение вашего Email - адреса</h2>
                <p class='text'>Спасибо за регистрацию в <strong style='color: {accentGreen};'>FundFighters</strong>!</p>
                <p class='text'>Вы на шаг ближе к контролю над своими финансами.</p>
                <p class='text'>Используйте код ниже для подтверждения вашего адреса и активации аккаунта.</p>

                <div class='verification-box'>
                    <span style='font-size: 16px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1.2px; margin-bottom: 16px; display: block;'>
                        Ваш код подтверждения
                    </span>
                    <div class='verification-code'>{code}</div>
                </div>

                <div class='security-box'>
                    <span class='security-title'>Безопасность</span>
                    <div class='security-text'>
                        <div style='margin-bottom: 8px;color: {textMuted}; '><strong>Никогда не делитесь этим кодом.</strong></div>
                        <div style='margin-bottom: 4px; color: {textMuted};'>Срок действия: <strong>24 часа</strong>.</div>
                        <div style='color: {textMuted};'>Код действует <strong>только один раз</strong>.</div>
                    </div>
                </div>

                <p class='text' style='font-size: 13px; margin-top: 24px;'>
                    Если это письмо пришло вам по ошибке, просто проигнорируйте его.<br>Ваш аккаунт не будет активирован без подтверждения кода.
                </p>
            </div>
        </div>
        <div class='footer'>
            <a href='#' class='footer-link'>Политика конфиденциальности</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Условия</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Поддержка</a>
            <div style='font-size: 11px; color: {accentGreen}; margin-top: 16px;'>© 2026 FundFighters Inc. Все права защищены.</div>
        </div>
    </div>
</body>
</html>";
    }

    public string GenerateResetPasswordHtmlTemplate(string code)
    {
        const string accentGreen = "#1E8C62";
        const string lightGreenBg = "#F0F9F5";
        const string securityBg = "#F4F7F6";
        const string textDark = "#000000";
        const string textMuted = "#555555";
        const string footerLinkColor = "#0056D2";

        var logoHtml = $@"<div style='width: 100%; text-align: center; margin-bottom: 24px;'>
            <center>
                <img src='{LogoUrl}' alt='FundFighters Logo' width='200' style='width: 200px; height: auto; border: 0; outline: none; text-decoration: none; display: inline-block; pointer-events: none; user-select: none;' />
            </center>
         </div>";

        return $@"<!DOCTYPE html>
<html lang='ru'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <link href='https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap' rel='stylesheet'>
    <style>
        body {{ font-family: 'Inter', -apple-system, sans-serif; background-color: #F4F4F4; margin: 0; padding: 0; }}
        .email-wrapper {{ background-color: #F4F4F4; padding: 40px 16px; }}
        .email-container {{ max-width: 540px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; }}
        .header {{ background-color: {lightGreenBg}; padding: 48px 36px; text-align: center; border-bottom: 2px solid {accentGreen}; }}
        .brand-name {{ font-size: 32px; font-weight: 900; color: {textDark}; margin-bottom: 8px; }}
        .brand-tagline {{ font-size: 11px; font-weight: 700; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1px; }}
        .body {{ padding: 44px 36px; }}
        .title {{ font-size: 22px; font-weight: 800; color: {textDark}; margin-bottom: 20px; }}
        .text {{ font-size: 15px; color: {textMuted}; line-height: 1.7; margin-bottom: 12px; }}
        .verification-box {{ background-color: {lightGreenBg}; border: 2px solid {accentGreen}; border-radius: 12px; padding: 36px 24px; text-align: center; margin: 32px 0; }}
        .verification-code {{ font-size: 48px; font-weight: 700; color: {accentGreen}; letter-spacing: 8px; font-family: 'Inter', sans-serif; }}
        .security-box {{ background-color: {securityBg}; border-left: 4px solid {accentGreen}; border-radius: 8px; padding: 20px; margin-bottom: 28px; }}
        .security-title {{ font-size: 11px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; margin-bottom: 12px; display: block; }}
        .security-text {{ font-size: 14px; color: {textDark}; line-height: 1.6; }}
        .security-text strong {{ font-weight: 700; }}
        .footer {{ padding: 32px; text-align: center; background-color: #F4F4F4; }}
        .footer-link {{ color: {footerLinkColor}; text-decoration: none; font-weight: 600; font-size: 13px; }}
        .footer-divider {{ color: #CCCCCC; margin: 0 8px; }}
    </style>
</head>
<body>
    <div class='email-wrapper'>
        <div class='email-container'>
            <div class='header'>
                {logoHtml}
                <div class='brand-name'>FundFighters</div>
                <div class='brand-tagline'>Управление Бюджетом</div>
            </div>
            <div class='body'>
                <h2 class='title'>Сброс пароля</h2>
                <p class='text'>Мы получили запрос на сброс пароля для вашего аккаунта <strong style='color: {accentGreen};'>FundFighters</strong>.</p>
                <p class='text'>Используйте этот код, чтобы задать новый пароль.</p>

                <div class='verification-box'>
                    <span style='font-size: 16px; font-weight: 800; color: {accentGreen}; text-transform: uppercase; letter-spacing: 1.2px; margin-bottom: 16px; display: block;'>
                        Ваш код для сброса пароля
                    </span>
                    <div class='verification-code'>{code}</div>
                </div>

                <div class='security-box'>
                    <span class='security-title'>Безопасность</span>
                    <div class='security-text'>
                        <div style='margin-bottom: 8px;color: {textMuted}; '><strong>Никогда не делитесь этим кодом.</strong></div>
                        <div style='margin-bottom: 4px; color: {textMuted};'>Срок действия: <strong>15 минут</strong>.</div>
                        <div style='color: {textMuted};'>Код действует <strong>только один раз</strong>.</div>
                    </div>
                </div>

                <p class='text' style='font-size: 13px; margin-top: 24px;'>
                    Если это не вы запрашивали сброс пароля, просто проигнорируйте письмо.<br>Ваш текущий пароль останется в безопасности.
                </p>
            </div>
        </div>
        <div class='footer'>
            <a href='#' class='footer-link'>Политика конфиденциальности</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Условия</a>
            <span class='footer-divider'>•</span>
            <a href='#' class='footer-link'>Поддержка</a>
            <div style='font-size: 11px; color: {accentGreen}; margin-top: 16px;'>© 2026 FundFighters Inc. Все права защищены.</div>
        </div>
    </div>
</body>
</html>";
    }
}