using MediatR;

namespace FundFighters.Backend.Application.Features.Auth.Commands;

public class UpdateProfileCommand : IRequest<UpdateProfileResponse>
{
    public string PlayerId { get; set; }
    public string Username { get; set; } = string.Empty;
}

public class UpdateProfileResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
}
