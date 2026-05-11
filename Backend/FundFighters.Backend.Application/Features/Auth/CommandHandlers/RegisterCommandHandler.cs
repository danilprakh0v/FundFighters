/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: RegisterCommandHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Auth/CommandHandlers/
Назначение: Обработчик команды регистрации новой учетной записи игрока.
            Валидирует данные, хеширует пароль и создает запись в БД.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Application.Interfaces;
using FundFighters.Backend.Domain.Entities;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.CommandHandlers;

/// <summary>
/// Обработчик регистрации нового игрока.
/// Выполняет проверку существования email, хеширование пароля через BCrypt
/// и инициализацию начального состояния игрового аккаунта.
/// </summary>
public class RegisterCommandHandler : IRequestHandler<RegisterCommand, RegisterResponse>
{
    private readonly IGameRepository _repository;
    private readonly IEmailService _emailService;
    private readonly ILogger<RegisterCommandHandler> _logger;

    public RegisterCommandHandler(
        IGameRepository repository,
        IEmailService emailService,
        ILogger<RegisterCommandHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<RegisterResponse> Handle(RegisterCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // Проверка обязательных полей
            if (string.IsNullOrWhiteSpace(request.Username) ||
                string.IsNullOrWhiteSpace(request.Email) ||
                string.IsNullOrWhiteSpace(request.Password))
            {
                return new RegisterResponse
                {
                    Success = false,
                    Message = "Username, email, and password are required."
                };
            }

            // Проверка на существование игрока с таким email
            var existingPlayer = await _repository.GetPlayerByEmailAsync(request.Email);
            if (existingPlayer != null)
            {
                _logger.LogWarning($"Registration attempt with existing email: {request.Email}");
                return new RegisterResponse
                {
                    Success = false,
                    Message = "Email already registered."
                };
            }

            // Генерация 6-значного кода подтверждения
            var verificationCode = GenerateVerificationCode();

            // Хеширование пароля
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            // Создание новой сущности игрока с начальными параметрами
            var player = new Player
            {
                Username = request.Username,
                Email = request.Email,
                PasswordHash = passwordHash,
                VerificationCode = verificationCode,
                IsVerified = false,
                Balance = 5000,
                Level = 1,
                CurrentXp = 0,
                XpToNextLevel = 100,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            // Сохранение игрока в базе данных
            await _repository.AddPlayerAsync(player);
            await _repository.SaveChangesAsync();

            // Отправка email с кодом верификации
            try
            {
                await _emailService.SendVerificationCodeAsync(request.Email, verificationCode);
                _logger.LogInformation($"Verification email sent to {request.Email}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send verification email to {request.Email}: {ex.Message}");
                // Не прерываем регистрацию, если возникла ошибка при отправке почты
            }

            return new RegisterResponse
            {
                Success = true,
                Message = "Registration successful! Please check your email for the verification code.",
                PlayerId = player.Id
            };
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error during registration: {ex.GetType().Name}");
            _logger.LogError($"Message: {ex.Message}");
            if (ex.InnerException != null)
            {
                _logger.LogError($"Inner exception: {ex.InnerException.Message}");
            }
            
            // Проверка на ошибку подключения к БД
            if (ex.Message.Contains("connection") || ex.Message.Contains("Connection refused") || 
                ex.GetType().Name.Contains("Npgsql"))
            {
                return new RegisterResponse
                {
                    Success = false,
                    Message = "Database connection failed. Please ensure PostgreSQL is running on localhost:5432."
                };
            }
            
            return new RegisterResponse
            {
                Success = false,
                Message = "An error occurred during registration. Please try again later."
            };
        }
    }

    /// <summary>
    /// Генерация случайного 6-значного кода верификации.
    /// </summary>
    private static string GenerateVerificationCode()
    {
        var random = new Random();
        return random.Next(100000, 999999).ToString();
    }
}
