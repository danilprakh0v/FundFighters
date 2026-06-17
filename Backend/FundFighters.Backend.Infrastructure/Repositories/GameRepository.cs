/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GameRepository.cs
Расположение: Backend/FundFighters.Backend.Infrastructure/Repositories/
Назначение: Реализация паттерна Repository для работы с игровыми данными.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;
using FundFighters.Backend.Domain.Interfaces;
using FundFighters.Backend.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace FundFighters.Backend.Infrastructure.Repositories;

/// <summary>
/// Реализация интерфейса IGameRepository для работы с БД через EF Core.
/// </summary>
public class GameRepository : IGameRepository
{
    private readonly AppDbContext _dbContext;

    public GameRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    /// <summary>
    /// Получение игрока по ID.
    /// </summary>
    public async Task<Player?> GetPlayerAsync(int playerId)
    {
        return await _dbContext.Players
            .Include(p => p.Transactions)
            .FirstOrDefaultAsync(p => p.Id == playerId);
    }

    /// <summary>
    /// Получение игрока по строковому ID.
    /// </summary>
    public async Task<Player?> GetPlayerByIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        if (int.TryParse(playerId, out var playerIdInt))
        {
            return await _dbContext.Players
                .Include(p => p.Transactions)
                .FirstOrDefaultAsync(p => p.Id == playerIdInt, cancellationToken);
        }
        return null;
    }

    /// <summary>
    /// Получение игрока по email.
    /// </summary>
    public async Task<Player?> GetPlayerByEmailAsync(string email)
    {
        return await _dbContext.Players
            .FirstOrDefaultAsync(p => p.Email == email);
    }

    /// <summary>
    /// Получение текущего активного врага.
    /// </summary>
    public async Task<Enemy?> GetCurrentEnemyAsync()
    {
        return await _dbContext.Enemies
            .Where(e => !e.IsDefeated)
            .FirstOrDefaultAsync();
    }

    /// <summary>
    /// Получение последних транзакций игрока.
    /// </summary>
    public async Task<List<Transaction>> GetRecentTransactionsAsync(int playerId, int count = 50)
    {
        return await _dbContext.Transactions
            .Where(t => t.PlayerId == playerId)
            .OrderByDescending(t => t.Date)
            .Take(count)
            .ToListAsync();
    }

    /// <summary>
    /// Получение всех транзакций игрока по строковому ID.
    /// </summary>
    public async Task<List<Transaction>> GetTransactionsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        if (int.TryParse(playerId, out var playerIdInt))
        {
            return await _dbContext.Transactions
                .Where(t => t.PlayerId == playerIdInt)
                .OrderByDescending(t => t.Date)
                .ToListAsync(cancellationToken);
        }
        return new List<Transaction>();
    }

    /// <summary>
    /// Получение всех целей сбережения игрока.
    /// </summary>
    public async Task<List<SavingsGoal>> GetSavingsGoalsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavingsGoals
            .Where(g => g.PlayerId == playerId)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Получение всех боев игрока.
    /// </summary>
    public async Task<List<Battle>> GetBattlesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Battles
            .Where(b => b.PlayerId == playerId)
            .OrderByDescending(b => b.BattleDate)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Получение всех категорий расходов игрока.
    /// </summary>
    public async Task<List<ExpenseCategory>> GetExpenseCategoriesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.ExpenseCategories
            .Where(c => c.PlayerId == playerId)
            .OrderBy(c => c.SortOrder)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Получение транзакции по ID.
    /// </summary>
    public async Task<Transaction?> GetTransactionByIdAsync(int transactionId)
    {
        return await _dbContext.Transactions.FindAsync(transactionId);
    }

    /// <summary>
    /// Удаление транзакции.
    /// </summary>
    public void DeleteTransaction(Transaction transaction)
    {
        _dbContext.Transactions.Remove(transaction);
    }

    /// <summary>
    /// Добавление нового игрока.
    /// </summary>
    public async Task AddPlayerAsync(Player player)
    {
        await _dbContext.Players.AddAsync(player);
    }

    /// <summary>
    /// Добавление новой транзакции.
    /// </summary>
    public async Task AddTransactionAsync(Transaction transaction)
    {
        var now = DateTime.UtcNow;
        if (transaction.Date == default)
        {
            transaction.Date = now;
        }
        transaction.CreatedAt = now;
        transaction.UpdatedAt = now;

        await _dbContext.Transactions.AddAsync(transaction);
    }

    /// <summary>
    /// Сохранение изменений в базе данных.
    /// </summary>
    public async Task SaveChangesAsync()
    {
        var entries = _dbContext.ChangeTracker.Entries()
            .Where(e => e.State == EntityState.Modified)
            .ToList();

        foreach (var entry in entries)
        {
            if (entry.Entity is BaseEntity baseEntity)
            {
                baseEntity.UpdatedAt = DateTime.UtcNow;
            }
        }

        await _dbContext.SaveChangesAsync();
    }

    /// <summary>
    /// Инициализация начальных данных для нового игрока.
    /// </summary>
    public async Task SeedPlayerDataAsync(int playerId)
    {
        var playerIdStr = playerId.ToString();

        var hasGoal = await _dbContext.Set<SavingsGoal>()
            .AnyAsync(g => g.PlayerId == playerIdStr);
        if (hasGoal) return;

        var goal = new SavingsGoal
        {
            GoalName = "PlayStation 5 Slim",
            Description = "Победите босса консолей, чтобы получить награду!",
            TargetAmount = 62000m,
            CurrentAmount = 23250m,
            ImageUrl = "ps5_slim_asset",
            IsActive = true,
            TotalHearts = 10,
            DefeatedHearts = 3,
            PlayerId = playerIdStr,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        await _dbContext.Set<SavingsGoal>().AddAsync(goal);

        var now = DateTime.UtcNow;
        var transactions = new[]
        {
            new Domain.Entities.Transaction
            {
                PlayerId = playerId, Title = "Заработная плата", Category = "Доход",
                Amount = 180000m, Type = Domain.Enums.TransactionType.Saving,
                Date = now.AddDays(-5), IconUrl = "salary_icon",
                CreatedAt = now.AddDays(-5), UpdatedAt = now.AddDays(-5)
            },
            new Domain.Entities.Transaction
            {
                PlayerId = playerId, Title = "Яндекс Плюс", Category = "Подписки",
                Amount = 400m, Type = Domain.Enums.TransactionType.Expense,
                Date = now.AddDays(-2), IconUrl = "yandex_icon",
                CreatedAt = now.AddDays(-2), UpdatedAt = now.AddDays(-2)
            },
            new Domain.Entities.Transaction
            {
                PlayerId = playerId, Title = "Spotify Premium", Category = "Подписки",
                Amount = 700m, Type = Domain.Enums.TransactionType.Expense,
                Date = now.AddDays(-1), IconUrl = "spotify_icon",
                CreatedAt = now.AddDays(-1), UpdatedAt = now.AddDays(-1)
            }
        };
        await _dbContext.Transactions.AddRangeAsync(transactions);
        await _dbContext.SaveChangesAsync();
    }
}
