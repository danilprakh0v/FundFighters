/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ResetPasswordCommand.cs
Назначение: CQRS команда для завершения сброса пароля.
===============================================================================
*/

using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Commands;

public class ResetPasswordCommand : IRequest<ResetPasswordResponse>
{
    public string Email { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}

public class ResetPasswordResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
}
