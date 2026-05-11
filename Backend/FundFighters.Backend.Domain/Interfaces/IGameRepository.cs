/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: IGameRepository.cs
Расположение: FundFighters.Backend.Domain/Interfaces/
Назначение: Интерфейс репозитория для операций доступа к игровым данным.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;

namespace FundFighters.Backend.Domain.Interfaces;

/// <summary>
/// Интерфейс репозитория для операций доступа к игровым данным.
/// Управляет извлечением и сохранением данных игроков, врагов и транзакций.
/// Определяет контракт, который должен реализовать слой Infrastructure.
/// 
/// Repository interface for game-related data access operations.
/// Handles retrieval and persistence of player, enemy, and transaction data.
/// Defines the contract that Infrastructure layer must implement.
/// </summary>
public interface IGameRepository
{
    /// <summary>
    /// Получает игрока по его ID.
    /// 
    /// Retrieves a player by their ID.
    /// </summary>
    /// <param name="playerId">ID игрока, который нужно получить (Player ID to retrieve)</param>
    /// <returns>Игрок или null если не найден (The player, or null if not found)</returns>
    Task<Player?> GetPlayerAsync(int playerId);

    /// <summary>
    /// Получает игрока по его строковому ID.
    /// 
    /// Retrieves a player by their string ID.
    /// </summary>
    /// <param name="playerId">ID игрока (string) (Player ID as string)</param>
    /// <param name="cancellationToken">Токен отмены (Cancellation token)</param>
    /// <returns>Игрок или null если не найден (The player, or null if not found)</returns>
    Task<Player?> GetPlayerByIdAsync(string playerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получает игрока по его email адресу.
    /// Используется для аутентификации и регистрации.
    /// 
    /// Retrieves a player by their email address.
    /// Used for authentication and registration.
    /// </summary>
    /// <param name="email">Email адрес для поиска (Email address to search for)</param>
    /// <returns>Игрок или null если не найден (The player, or null if not found)</returns>
    Task<Player?> GetPlayerByEmailAsync(string email);

    /// <summary>
    /// Получает текущего активного врага (первого непобежденного врага).
    /// 
    /// Retrieves the current active enemy (first non-defeated enemy).
    /// </summary>
    /// <returns>Текущий враг или null если врага нет (The current enemy, or null if no enemy is active)</returns>
    Task<Enemy?> GetCurrentEnemyAsync();

    /// <summary>
    /// Получает последние транзакции игрока.
    /// Используется для отображения списка недавней активности в UI.
    /// 
    /// Retrieves the most recent transactions for a player.
    /// Used for displaying Recent Activity list in UI.
    /// </summary>
    /// <param name="playerId">ID игрока (The ID of the player)</param>
    /// <param name="count">Количество последних транзакций для получения (по умолчанию: 50 для аналитики) (Number of recent transactions to retrieve - default: 50 for analytics)</param>
    /// <returns>Список транзакций, отсортированный по дате (новые первыми) (List of transactions ordered by date - newest first)</returns>
    Task<List<Transaction>> GetRecentTransactionsAsync(int playerId, int count = 50);

    /// <summary>
    /// Получает все транзакции игрока по его строковому ID.
    /// 
    /// Retrieves all transactions for a player by their string ID.
    /// </summary>
    /// <param name="playerId">ID игрока (string) (Player ID as string)</param>
    /// <param name="cancellationToken">Токен отмены (Cancellation token)</param>
    /// <returns>Список всех транзакций (List of all transactions)</returns>
    Task<List<Transaction>> GetTransactionsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получает все цели сбережения игрока.
    /// 
    /// Retrieves all savings goals for a player.
    /// </summary>
    /// <param name="playerId">ID игрока (Player ID)</param>
    /// <param name="cancellationToken">Токен отмены (Cancellation token)</param>
    /// <returns>Список целей сбережения (List of savings goals)</returns>
    Task<List<SavingsGoal>> GetSavingsGoalsByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получает все боевые записи игрока.
    /// 
    /// Retrieves all battles for a player.
    /// </summary>
    /// <param name="playerId">ID игрока (Player ID)</param>
    /// <param name="cancellationToken">Токен отмены (Cancellation token)</param>
    /// <returns>Список боев (List of battles)</returns>
    Task<List<Battle>> GetBattlesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получает категорию расходов игрока по ID.
    /// </summary>
    Task<List<ExpenseCategory>> GetExpenseCategoriesByPlayerIdAsync(string playerId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Получает транзакцию по ID.
    /// </summary>
    Task<Transaction?> GetTransactionByIdAsync(int transactionId);

    /// <summary>
    /// Удаляет транзакцию.
    /// </summary>
    void DeleteTransaction(Transaction transaction);

    /// <summary>
    /// Добавляет нового игрока в репозиторий.
    /// Используется во время регистрации.
    /// 
    /// Adds a new player to the repository.
    /// Used during registration.
    /// </summary>
    /// <param name="player">Игрок для добавления (The player to add)</param>
    Task AddPlayerAsync(Player player);

    /// <summary>
    /// Добавляет новую транзакцию для игрока.
    /// 
    /// Adds a new transaction for a player.
    /// </summary>
    /// <param name="transaction">Транзакция для добавления (The transaction to add)</param>
    Task AddTransactionAsync(Transaction transaction);

    /// <summary>
    /// Сохраняет все изменения, сделанные в сущностях, в базу данных.
    /// 
    /// Persists all changes made to entities to the database.
    /// </summary>
    Task SaveChangesAsync();

    /// <summary>
    /// Создаёт начальные данные для нового игрока после верификации email.
    /// Включает цель сбережения и примеры транзакций.
    /// 
    /// Seeds initial data for a new player after email verification.
    /// Includes a savings goal and sample transactions.
    /// </summary>
    Task SeedPlayerDataAsync(int playerId);
}

