/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: VerifyEmailCommandHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Auth/CommandHandlers/
Назначение: Обработчик команды верификации email адреса.
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
/// Обработчик верификации почтового адреса игрока.
/// Сверяет введенный код с кодом из БД, активирует аккаунт
/// и инициализирует демонстрационные данные для нового пользователя.
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
            // Проверка входных данных
            if (string.IsNullOrWhiteSpace(request.Email) || string.IsNullOrWhiteSpace(request.Code))
            {
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Email and verification code are required."
                };
            }

            // Поиск игрока по email
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

            // Проверка, не была ли верификация уже пройдена
            if (player.IsVerified)
            {
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Email is already verified."
                };
            }

            // Валидация кода подтверждения
            if (player.VerificationCode != request.Code)
            {
                _logger.LogWarning($"Invalid verification code for {request.Email}");
                return new VerifyEmailResponse
                {
                    Success = false,
                    Message = "Invalid verification code."
                };
            }

            // Обновление статуса игрока
            player.IsVerified = true;
            player.VerificationCode = null;
            player.UpdatedAt = DateTime.UtcNow;
            player.Balance = 145000.99m;

            // Сохранение изменений в БД
            await _repository.SaveChangesAsync();
            
            // Инициализация начальных игровых данных (категории, цели и т.д.)
            await _repository.SeedPlayerDataAsync(player.Id);
            
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
