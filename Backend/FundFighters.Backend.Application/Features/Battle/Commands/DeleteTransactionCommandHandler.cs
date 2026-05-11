/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: DeleteTransactionCommandHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Battle/Commands/
Назначение: Обработчик команды удаления транзакции.
            Корректирует баланс игрока и удаляет запись из БД.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Interfaces;
using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Commands;

/// <summary>
/// Обработчик удаления финансовой транзакции.
/// Перед удалением производит обратную корректировку баланса игрока,
/// чтобы состояние счета оставалось консистентным.
/// </summary>
public class DeleteTransactionCommandHandler : IRequestHandler<DeleteTransactionCommand, bool>
{
    private readonly IGameRepository _gameRepository;

    public DeleteTransactionCommandHandler(IGameRepository gameRepository)
    {
        _gameRepository = gameRepository ?? throw new ArgumentNullException(nameof(gameRepository));
    }

    public async Task<bool> Handle(DeleteTransactionCommand request, CancellationToken cancellationToken)
    {
        // Поиск транзакции по ID
        var transaction = await _gameRepository.GetTransactionByIdAsync(request.TransactionId);

        if (transaction == null || transaction.PlayerId != request.PlayerId)
            return false;

        // Корректировка баланса игрока перед удалением транзакции
        var player = await _gameRepository.GetPlayerAsync(request.PlayerId);
        if (player != null)
        {
            if (transaction.Type == Domain.Enums.TransactionType.Saving)
            {
                player.Balance -= transaction.Amount;
            }
            else
            {
                player.Balance += transaction.Amount;
            }
        }

        // Удаление записи из БД
        _gameRepository.DeleteTransaction(transaction);
        await _gameRepository.SaveChangesAsync();
        
        return true;
    }
}
