/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ResetPasswordCommandHandler.cs
Назначение: Обработчик команды завершения сброса пароля.
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.CommandHandlers;

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
        var player = await _repository.GetPlayerByEmailAsync(request.Email);
        if (player == null || player.VerificationCode != request.Code)
        {
            return new ResetPasswordResponse { Success = false, Message = "Invalid email or verification code." };
        }

        // Hash new password
        player.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
        player.VerificationCode = null; // Clear code
        player.UpdatedAt = DateTime.UtcNow;

        await _repository.SaveChangesAsync();

        return new ResetPasswordResponse { Success = true, Message = "Password has been reset successfully." };
    }
}
