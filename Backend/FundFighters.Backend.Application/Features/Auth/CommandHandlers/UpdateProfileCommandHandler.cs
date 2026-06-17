using FundFighters.Backend.Application.Features.Auth.Commands;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Application.Features.Auth.CommandHandlers;

public class UpdateProfileCommandHandler : IRequestHandler<UpdateProfileCommand, UpdateProfileResponse>
{
    private readonly IGameRepository _repository;
    private readonly ILogger<UpdateProfileCommandHandler> _logger;

    public UpdateProfileCommandHandler(IGameRepository repository, ILogger<UpdateProfileCommandHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<UpdateProfileResponse> Handle(UpdateProfileCommand request, CancellationToken cancellationToken)
    {
        try
        {
            var player = await _repository.GetPlayerByIdAsync(request.PlayerId, cancellationToken);
            if (player == null)
            {
                return new UpdateProfileResponse { Success = false, Message = "User not found." };
            }

            if (!string.IsNullOrWhiteSpace(request.Username))
            {
                player.Username = request.Username;
                await _repository.SaveChangesAsync();
            }

            return new UpdateProfileResponse { Success = true, Message = "Profile updated successfully.", Username = player.Username };
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error updating profile: {ex.Message}");
            return new UpdateProfileResponse { Success = false, Message = "An error occurred." };
        }
    }
}
