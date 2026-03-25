namespace FundFighters.Backend.Application.Interfaces;

public interface IJwtService
{
    string GenerateToken(string playerId, string email, string username);
}
