/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ProcessTransactionCommandHandler.cs
Расположение: FundFighters.Backend.Application/Features/Battle/Commands/
Назначение: CQRS handler для обработки финансовой транзакции в боевой системе.
            Обновляет баланс, наносит урон врагу и записывает транзакцию.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Domain.Entities;
using FundFighters.Backend.Domain.Enums;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Commands;

/// <summary>
/// CQRS handler для обработки финансовой транзакции в боевой системе.
/// Обновляет баланс и опыт игрока, наносит урон врагу, записывает транзакцию.
/// Возвращает обновленное состояние боя со списком недавних транзакций.
/// 
/// Handler for ProcessTransactionCommand.
/// Processes a financial transaction, updates player balance and enemy health.
/// Returns updated battle state with recent transactions list.
/// </summary>
public class ProcessTransactionCommandHandler : IRequestHandler<ProcessTransactionCommand, BattleStateDto>
{
    private readonly IGameRepository _gameRepository;

    public ProcessTransactionCommandHandler(IGameRepository gameRepository)
    {
        _gameRepository = gameRepository ?? throw new ArgumentNullException(nameof(gameRepository));
    }

    public async Task<BattleStateDto> Handle(ProcessTransactionCommand request, CancellationToken cancellationToken)
    {
        // Load player and enemy
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

        // Create transaction record with title and category
        var transaction = new Transaction
        {
            PlayerId = request.PlayerId,
            Amount = request.Amount,
            Type = request.Type,
            Title = request.Title,
            Category = request.Category,
            Date = DateTime.UtcNow
        };

        // Process transaction based on type
        if (request.Type == TransactionType.Saving)
        {
            // Increase player balance and add XP
            player.AddTransaction(request.Amount, TransactionType.Saving);
            
            // Deal damage to enemy
            enemy.TakeDamage(request.Amount);
        }
        else if (request.Type == TransactionType.Expense)
        {
            // Decrease player balance
            player.AddTransaction(request.Amount, TransactionType.Expense);
        }

        // Save changes
        await _gameRepository.AddTransactionAsync(transaction);
        await _gameRepository.SaveChangesAsync();

        // Get recent transactions for response
        var recentTransactions = await _gameRepository.GetRecentTransactionsAsync(request.PlayerId, count: 5);

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
