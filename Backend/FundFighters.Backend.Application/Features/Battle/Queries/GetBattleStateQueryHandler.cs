/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GetBattleStateQueryHandler.cs
Расположение: FundFighters.Backend.Application/Features/Battle/Queries/
Назначение: CQRS handler для получения текущего состояния боевой системы.
            Собирает информацию о боевом состоянии и историю транзакций.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Queries;

/// <summary>
/// CQRS handler для получения текущего состояния боевой системы игрока.
/// Собирает полную информацию о боевом статусе, враге, балансе и истории транзакций.
/// Используется для отображения боевого интерфейса и виджета недавних операций.
/// 
/// Handler for GetBattleStateQuery.
/// Retrieves the current battle state for a player including enemy, balance, and recent transactions.
/// Used to display battle interface and recent activity widget.
/// </summary>
public class GetBattleStateQueryHandler : IRequestHandler<GetBattleStateQuery, BattleStateDto>
{
    private readonly IGameRepository _gameRepository;

    public GetBattleStateQueryHandler(IGameRepository gameRepository)
    {
        _gameRepository = gameRepository ?? throw new ArgumentNullException(nameof(gameRepository));
    }

    public async Task<BattleStateDto> Handle(GetBattleStateQuery request, CancellationToken cancellationToken)
    {
        var player = await _gameRepository.GetPlayerAsync(request.PlayerId);
        if (player == null)
        {
            throw new InvalidOperationException($"Player with ID {request.PlayerId} not found.");
        }

        var enemy = await _gameRepository.GetCurrentEnemyAsync();
        if (enemy == null)
        {
            throw new InvalidOperationException("No active enemy found.");
        }

        // Get recent transactions for Dashboard charts and transaction history (50 for analytics)
        var recentTransactions = await _gameRepository.GetRecentTransactionsAsync(request.PlayerId, count: 50);
        
        var hpPercentage = enemy.MaxHp > 0 
            ? (enemy.CurrentHp / enemy.MaxHp) * 100 
            : 0;

        return new BattleStateDto
        {
            PlayerBalance = player.Balance,
            PlayerLevel = player.Level,
            EnemyName = enemy.Name,
            EnemyCurrentHp = enemy.CurrentHp,
            EnemyMaxHp = enemy.MaxHp,
            HpPercentage = Math.Max(0, (double)hpPercentage),
            IsEnemyDefeated = enemy.IsDefeated,
            EnemyImageUrl = enemy.ImageUrl,
            RecentTransactions = recentTransactions
                .Select(t => new TransactionPreviewDto
                {
                    Id = t.Id,
                    Title = t.Title,
                    Amount = t.Amount,
                    Category = t.Category,
                    Date = t.Date,
                    Type = t.Type,
                    IconUrl = t.IconUrl
                })
                .ToList()
        };
    }
}
