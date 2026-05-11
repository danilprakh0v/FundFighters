using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Commands;

public class DeleteTransactionCommand : IRequest<bool>
{
    public int TransactionId { get; set; }
    public int PlayerId { get; set; }

    public DeleteTransactionCommand(int transactionId, int playerId)
    {
        TransactionId = transactionId;
        PlayerId = playerId;
    }
}
