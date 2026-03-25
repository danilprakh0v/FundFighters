/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ForgotPasswordCommand.cs
Назначение: CQRS команда для инициации сброса пароля.
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Commands;

public class ForgotPasswordCommand : IRequest<ForgotPasswordResponse>
{
    public string Email { get; set; } = string.Empty;
}

public class ForgotPasswordResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}
