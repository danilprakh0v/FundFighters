/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: ResetPasswordCommandHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Auth/CommandHandlers/
Назначение: Обработчик команды завершения сброса пароля.
            Устанавливает новый пароль после успешной проверки кода.
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
/// Обработчик финализации сброса пароля.
/// Проверяет корректность связки email + код восстановления,
/// выполняет хеширование нового пароля и сохранение изменений.
/// </summary>
public class ResetPasswordCommandHandler : IRequestHandler<ResetPasswordCommand, ResetPasswordResponse>
{
    private readonly IGameRepository _repository;
    private readonly ILogger<ResetPasswordCommandHandler> _logger;

    public ResetPasswordCommandHandler(IGameRepository repository, ILogger<ResetPasswordCommandHandler> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<ResetPasswordResponse> Handle(ResetPasswordCommand request, CancellationToken cancellationToken)
    {
        // Проверка соответствия кода восстановления
        var player = await _repository.GetPlayerByEmailAsync(request.Email);
        if (player == null || player.VerificationCode != request.Code)
        {
            _logger.LogWarning($"Failed password reset attempt for: {request.Email}");
            return new ResetPasswordResponse { Success = false, Message = "Invalid email or verification code." };
        }

        // Хеширование и установка нового пароля
        player.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        player.VerificationCode = null; // Очистка кода после использования
        player.UpdatedAt = DateTime.UtcNow;

        await _repository.SaveChangesAsync();

        _logger.LogInformation($"Password reset successfully for: {request.Email}");
        return new ResetPasswordResponse { Success = true, Message = "Password has been reset successfully." };
    }
}
