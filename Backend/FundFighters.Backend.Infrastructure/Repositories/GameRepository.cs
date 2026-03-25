/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GameRepository.cs
Расположение: FundFighters.Backend.Infrastructure/Repositories/
Назначение: Реализация паттерна Repository для работы с игровыми данными.
            Обрабатывает все операции доступа к данным через Entity Framework Core.
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
/// Реализация интерфейса IGameRepository с использованием Entity Framework Core.
/// Обрабатывает все операции доступа к данным для игровой системы (игроки, враги, транзакции).
/// Предоставляет асинхронные методы для выполнения CRUD операций.
/// 
/// Implementation of IGameRepository using Entity Framework Core.
/// Handles all game-related data access operations.
/// Provides asynchronous methods for CRUD operations.
/// </summary>
public class GameRepository : IGameRepository
{
    private readonly AppDbContext _dbContext;

    public GameRepository(AppDbContext dbContext)
    {
        _dbContext = dbContext ?? throw new ArgumentNullException(nameof(dbContext));
    }

    /// <summary>
    /// Retrieves a player by their ID.
    /// </summary>
    public async Task<Player?> GetPlayerAsync(int playerId)
    {
        return await _dbContext.Players
            .Include(p => p.Transactions)
            .FirstOrDefaultAsync(p => p.Id == playerId);
    }

    /// <summary>
    /// Retrieves a player by their string ID.
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
    /// Retrieves a player by their email address.
    /// Used for authentication and registration.
    /// </summary>
    public async Task<Player?> GetPlayerByEmailAsync(string email)
    {
        return await _dbContext.Players
            .FirstOrDefaultAsync(p => p.Email == email);
    }

    /// <summary>
    /// Retrieves the current active enemy (first non-defeated enemy).
    /// </summary>
    public async Task<Enemy?> GetCurrentEnemyAsync()
    {
        return await _dbContext.Enemies
            .Where(e => !e.IsDefeated)
            .FirstOrDefaultAsync();
    }

    /// <summary>
    /// Retrieves the most recent transactions for a player, ordered by date descending.
    /// Used for displaying Recent Activity list in the UI (50 for analytics).
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
    /// Retrieves all transactions for a player by their string ID.
    /// </summary>
    public async Task<List<Transaction>> GetTransactionsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        if (int.TryParse(playerId, out var playerIdInt))
        {
            return await _dbContext.Transactions
                .Where(t => t.PlayerId == playerIdInt)
                .OrderByDescending(t => t.CreatedAt)
                .ToListAsync(cancellationToken);
        }
        return new List<Transaction>();
    }

    /// <summary>
    /// Retrieves all savings goals for a player.
    /// </summary>
    public async Task<List<SavingsGoal>> GetSavingsGoalsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavingsGoals
            .Where(g => g.PlayerId == playerId)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Retrieves all battles for a player.
    /// </summary>
    public async Task<List<Battle>> GetBattlesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Battles
            .Where(b => b.PlayerId == playerId)
            .OrderByDescending(b => b.BattleDate)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Retrieves all expense categories for a player.
    /// </summary>
    public async Task<List<ExpenseCategory>> GetExpenseCategoriesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.ExpenseCategories
            .Where(c => c.PlayerId == playerId)
            .OrderBy(c => c.SortOrder)
            .ToListAsync(cancellationToken);
    }

    /// <summary>
    /// Adds a new player to the database.
    /// Used during user registration.
    /// </summary>
    public async Task AddPlayerAsync(Player player)
    {
        await _dbContext.Players.AddAsync(player);
    }

    /// <summary>
    /// Adds a new transaction to the database.
    /// </summary>
    public async Task AddTransactionAsync(Transaction transaction)
    {
        transaction.Date = DateTime.UtcNow;
        transaction.CreatedAt = DateTime.UtcNow;
        transaction.UpdatedAt = DateTime.UtcNow;

        await _dbContext.Transactions.AddAsync(transaction);
    }

    /// <summary>
    /// Persists all changes made to the context to the database.
    /// </summary>
    public async Task SaveChangesAsync()
    {
        // Update the UpdatedAt timestamp for modified entities
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
}
