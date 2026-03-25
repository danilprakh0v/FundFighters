/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: VerifyLoginCodeQueryHandler.cs
Расположение: FundFighters.Backend.Application/Features/Auth/QueryHandlers/
Назначение: CQRS handler для подтверждения кода двухфакторной аутентификации.
            Проверяет код и завершает вход.
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
/// CQRS handler для подтверждения кода двухфакторной аутентификации.
/// Проверяет предоставленный код против сохраненного и завершает процесс входа.
/// 
/// Handler for verifying two-factor authentication code.
/// Validates the provided code against the stored one and completes login.
/// </summary>
public class VerifyLoginCodeQueryHandler : IRequestHandler<VerifyLoginCodeQuery, VerifyLoginCodeResponse>
{
    private readonly IGameRepository _repository;
    private readonly IJwtService _jwtService;
    private readonly ILogger<VerifyLoginCodeQueryHandler> _logger;

    public VerifyLoginCodeQueryHandler(
        IGameRepository repository,
        IJwtService jwtService,
        ILogger<VerifyLoginCodeQueryHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _jwtService = jwtService ?? throw new ArgumentNullException(nameof(jwtService));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<VerifyLoginCodeResponse> Handle(VerifyLoginCodeQuery request, CancellationToken cancellationToken)
    {
        try
        {
            // Validate input
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Code))
            {
                return new VerifyLoginCodeResponse
                {
                    Success = false,
                    Message = "Email and code are required."
                };
            }

            // Find player by email
            var player = await _repository.GetPlayerByEmailAsync(request.Email);
            if (player == null)
            {
                _logger.LogWarning($"Verify code attempt for non-existent email: {request.Email}");
                return new VerifyLoginCodeResponse
                {
                    Success = false,
                    Message = "Invalid request."
                };
            }

            // Check if two-factor code exists and matches
            if (string.IsNullOrEmpty(player.TwoFactorCode) || player.TwoFactorCode != request.Code)
            {
                _logger.LogWarning($"Invalid two-factor code for email: {request.Email}");
                return new VerifyLoginCodeResponse
                {
                    Success = false,
                    Message = "Invalid verification code."
                };
            }

            // Clear the two-factor code after successful verification
            player.TwoFactorCode = null;
            await _repository.SaveChangesAsync();

            _logger.LogInformation($"Successful two-factor verification for: {request.Email}");

            var token = _jwtService.GenerateToken(player.Id.ToString(), player.Email, player.Username);

            return new VerifyLoginCodeResponse
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
            _logger.LogError($"Error during two-factor verification: {ex.Message}");
            return new VerifyLoginCodeResponse
            {
                Success = false,
                Message = "An error occurred during verification."
            };
        }
    }
}