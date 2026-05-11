/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: ProcessTransactionCommandHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Battle/Commands/
Назначение: Обработчик финансовой транзакции в боевой системе.
            Обновляет баланс игрока и записывает транзакцию в БД.
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
/// Обработчик финансовой транзакции.
/// Обновляет текущий баланс игрока на основе типа транзакции (доход/расход)
/// и возвращает актуальное состояние боя с обновленным списком транзакций.
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
        // Поиск игрока в репозитории
        var player = await _gameRepository.GetPlayerAsync(request.PlayerId);
        if (player == null)
        {
            throw new InvalidOperationException($"Player with ID {request.PlayerId} not found.");
        }

        // Создание новой записи о транзакции
        var transaction = new Transaction
        {
            PlayerId = request.PlayerId,
            Amount = request.Amount,
            Type = request.Type,
            Title = request.Title,
            Category = request.Category,
            Date = DateTime.UtcNow
        };

        // Логика изменения баланса игрока
        player.AddTransaction(request.Amount, request.Type);

        // Сохранение транзакции в базу данных
        await _gameRepository.AddTransactionAsync(transaction);
        await _gameRepository.SaveChangesAsync();

        // Получение списка последних транзакций для обновления UI
        var recentTransactions = await _gameRepository.GetRecentTransactionsAsync(request.PlayerId, count: 5);

        return new BattleStateDto
        {
            PlayerBalance = player.Balance,
            PlayerLevel = player.Level,
            EnemyName = string.Empty,
            EnemyCurrentHp = 0,
            EnemyMaxHp = 0,
            HpPercentage = 0,
            IsEnemyDefeated = false,
            EnemyImageUrl = string.Empty,
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
