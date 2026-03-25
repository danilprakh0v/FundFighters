/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ForgotPasswordCommandHandler.cs
Назначение: Обработчик команды инициации сброса пароля.
===============================================================================
*/

using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Application.Interfaces;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.CommandHandlers;

public class ForgotPasswordCommandHandler : IRequestHandler<ForgotPasswordCommand, ForgotPasswordResponse>
{
    private readonly IGameRepository _repository;
    private readonly IEmailService _emailService;
    private readonly ILogger<ForgotPasswordCommandHandler> _logger;

    public ForgotPasswordCommandHandler(
        IGameRepository repository,
        IEmailService emailService,
        ILogger<ForgotPasswordCommandHandler> logger)
    {
        _repository = repository;
        _emailService = emailService;
        _logger = logger;
    }

    public async Task<ForgotPasswordResponse> Handle(ForgotPasswordCommand request, CancellationToken cancellationToken)
    {
        var player = await _repository.GetPlayerByEmailAsync(request.Email);
        if (player == null)
        {
            // For security, don't reveal if user exists, but here we might want to be explicit for MVP
            return new ForgotPasswordResponse { Success = false, Message = "User not found." };
        }

        var code = new Random().Next(100000, 999999).ToString();
        player.VerificationCode = code;
        player.UpdatedAt = DateTime.UtcNow;

        await _repository.SaveChangesAsync();

        try
        {
            var body = _emailService.GenerateResetPasswordHtmlTemplate(code);
            await _emailService.SendEmailAsync(request.Email, "FundFighters — Сброс пароля", body);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Failed to send reset email: {ex.Message}");
            return new ForgotPasswordResponse { Success = false, Message = "Failed to send email." };
        }

        return new ForgotPasswordResponse { Success = true, Message = "Reset code sent to your email." };
    }
}
