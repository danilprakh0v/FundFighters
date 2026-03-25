/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: VerifyEmailCommandHandler.cs
Расположение: FundFighters.Backend.Application/Features/Auth/CommandHandlers/
Назначение: CQRS handler для обработки команды верификации email адреса.
            Проверяет корректность кода и активирует учетную запись.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.CommandHandlers;

/// <summary>
/// CQRS handler для обработки команды верификации email адреса игрока.
/// Валидирует код подтверждения, проверяет его соответствие и активирует учетную запись.
/// Генерирует и возвращает JWT токен для дальнейшей аутентификации.
/// 
/// Handler for the VerifyEmailCommand.
/// Validates the verification code and marks the player's email as verified.
/// Generates and returns JWT token for subsequent authentication.
/// </summary>
public class VerifyEmailCommandHandler : IRequestHandler<VerifyEmailCommand, VerifyEmailResponse>
{
    private readonly IGameRepository _repository;
    private readonly ILogger<VerifyEmailCommandHandler> _logger;

    public VerifyEmailCommandHandler(
        IGameRepository repository,
        ILogger<VerifyEmailCommandHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<VerifyEmailResponse> Handle(VerifyEmailCommand request, CancellationToken cancellationToken)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Code))
            {
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Email and verification code are required."
                };
            }

            // Find player by email
            var player = await _repository.GetPlayerByEmailAsync(request.Email);
            if (player == null)
            {
                _logger.LogWarning($"Verification attempt for non-existent email: {request.Email}");
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Player not found."
                };
            }

            // Check if already verified
            if (player.IsVerified)
            {
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Email is already verified."
                };
            }

            // Validate verification code
            if (player.VerificationCode != request.Code)
            {
                _logger.LogWarning($"Invalid verification code for {request.Email}");
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Invalid verification code."
                };
            }

            // Mark as verified
            player.IsVerified = true;
            player.VerificationCode = null;
            player.UpdatedAt = DateTime.UtcNow;

            // Save changes
            await _repository.SaveChangesAsync();

            _logger.LogInformation($"Email verified for player: {request.Email}");

            return new VerifyEmailResponse
            {
                Success = true,
                Message = "Email verified successfully! You can now log in.",
                PlayerId = player.Id
            };
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error during email verification: {ex.Message}");
            return new VerifyEmailResponse
            {
                Success = false,
                Message = "An error occurred during verification."
            };
        }
    }
}
