/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: RegisterCommandHandler.cs
Расположение: FundFighters.Backend.Application/Features/Auth/CommandHandlers/
Назначение: CQRS handler для обработки команды регистрации новой учетной записи.
            Валидирует данные, хеширует пароль, создает игрока и отправляет email.
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
/// CQRS handler для обработки команды регистрации новой учетной записи игрока.
/// Валидирует входные данные, создает нового игрока, хеширует пароль с BCrypt,
/// генерирует код верификации и отправляет email с подтверждением.
/// 
/// CQRS handler to process player registration command.
/// Validates input, creates new player account, hashes password with BCrypt,
/// generates verification code and sends confirmation email.
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
            // Validate input
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

            // Check if email already exists
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

            // Generate verification code (6 digits)
            var verificationCode = GenerateVerificationCode();

            // Hash the password
            var passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            // Create new player
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

            // Save player to database
            await _repository.AddPlayerAsync(player);
            await _repository.SaveChangesAsync();

            // Send verification email
            try
            {
                await _emailService.SendVerificationCodeAsync(request.Email, verificationCode);
                _logger.LogInformation($"Verification email sent to {request.Email}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Failed to send verification email to {request.Email}: {ex.Message}");
                // Don't fail registration if email send fails, but log it
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
            
            // Check if it's a database connection error
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
    /// Generates a random 6-digit verification code.
    /// </summary>
    private static string GenerateVerificationCode()
    {
        var random = new Random();
        return random.Next(100000, 999999).ToString();
    }
}
