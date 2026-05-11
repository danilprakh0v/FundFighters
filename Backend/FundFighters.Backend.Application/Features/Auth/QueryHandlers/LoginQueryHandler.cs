/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: LoginQueryHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Auth/QueryHandlers/
Назначение: Обработчик запроса аутентификации игрока.
            Проверяет учетные данные и генерирует JWT токен.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Queries;
using FundFighters.Backend.Application.Interfaces;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.QueryHandlers;

/// <summary>
/// Обработчик входа в систему (Login).
/// Проверяет корректность email/пароля, статус верификации аккаунта
/// и генерирует токен доступа JWT при успешном сопоставлении данных.
/// </summary>
public class LoginQueryHandler : IRequestHandler<LoginQuery, LoginResponse>
{
    private readonly IGameRepository _repository;
    private readonly IEmailService _emailService;
    private readonly IJwtService _jwtService;
    private readonly ILogger<LoginQueryHandler> _logger;

    public LoginQueryHandler(
        IGameRepository repository,
        IEmailService emailService,
        IJwtService jwtService,
        ILogger<LoginQueryHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        _jwtService = jwtService ?? throw new ArgumentNullException(nameof(jwtService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<LoginResponse> Handle(LoginQuery request, CancellationToken cancellationToken)
    {
        try
        {
            // Проверка входных данных
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Password))
            {
                return new LoginResponse
                {
                    Success = false,
                    Message = "Email and password are required."
                };
            }

            // Поиск игрока по email
            var player = await _repository.GetPlayerByEmailAsync(request.Email);
            if (player == null)
            {
                _logger.LogWarning($"Login attempt for non-existent email: {request.Email}");
                return new LoginResponse
                {
                    Success = false,
                    Message = "Invalid email or password."
                };
            }

            // Проверка статуса верификации
            if (!player.IsVerified)
            {
                _logger.LogWarning($"Login attempt with unverified email: {request.Email}");
                return new LoginResponse
                {
                    Success = false,
                    Message = "Please verify your email before logging in."
                };
            }

            // Валидация хеша пароля
            if (!BCrypt.Net.BCrypt.Verify(request.Password, player.PasswordHash))
            {
                _logger.LogWarning($"Invalid password for email: {request.Email}");
                return new LoginResponse
                {
                    Success = false,
                    Message = "Invalid email or password."
                };
            }

            // Обработка двухфакторной аутентификации (если включена)
            if (player.IsTwoFactorEnabled)
            {
                var twoFactorCode = GenerateVerificationCode();

                player.TwoFactorCode = twoFactorCode;
                await _repository.SaveChangesAsync();

                try
                {
                    await _emailService.SendLoginVerificationCodeAsync(request.Email, twoFactorCode);
                    _logger.LogInformation($"Two-factor code sent to {request.Email}");
                }
                catch (Exception ex)
                {
                    _logger.LogError($"Failed to send two-factor code to {request.Email}: {ex.Message}");
                    return new LoginResponse
                    {
                        Success = false,
                        Message = "Failed to send verification code. Please try again."
                    };
                }

                return new LoginResponse
                {
                    Success = true,
                    Message = "Two-factor authentication code sent to your email.",
                    RequiresTwoFactor = true,
                    PlayerId = player.Id,
                    Username = player.Username
                };
            }

            _logger.LogInformation($"Successful login for: {request.Email}");

            // Генерация JWT токена
            var token = _jwtService.GenerateToken(player.Id.ToString(), player.Email, player.Username);

            return new LoginResponse
            {
                Success = true,
                Message = "Login successful!",
                Token = token,
                PlayerId = player.Id,
                Username = player.Username
            };
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error during login: {ex.Message}");
            return new LoginResponse
            {
                Success = false,
                Message = "An error occurred during login."
            };
        }
    }

    /// <summary>
    /// Генерация случайного 6-значного кода.
    /// </summary>
    private static string GenerateVerificationCode()
    {
        var random = new Random();
        return random.Next(100000, 999999).ToString();
    }
}
