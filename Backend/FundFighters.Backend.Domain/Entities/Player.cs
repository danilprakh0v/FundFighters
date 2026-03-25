/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Player.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Богатая модель предметной области, представляющая игрока в системе.
            Инкапсулирует состояние игрока и бизнес-логику управления балансом и опытом.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;
using FundFighters.Backend.Domain.Enums;

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Богатая модель предметной области, представляющая игрока в системе.
/// Инкапсулирует состояние игрока: баланс, уровень, опыт и транзакции.
/// Содержит бизнес-логику для управления финансами и развитием персонажа.
/// 
/// Rich domain model representing a player in the game.
/// Encapsulates player state: balance, level, experience, and transactions.
/// Contains business logic for managing finances and character development.
/// </summary>
public class Player : BaseEntity
{
    /// <summary>
    /// Имя пользователя (nickname) игрока для отображения в интерфейсе.
    /// Player's username for display in the interface.
    /// </summary>
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// Email адрес игрока (обязателен для аутентификации и верификации).
    /// Player's email address (required for authentication and verification).
    /// </summary>
    public required string Email { get; set; }

    /// <summary>
    /// Хешированный пароль с использованием BCrypt (не хранится в открытом виде).
    /// Hashed password using BCrypt (never stored in plain text).
    /// </summary>
    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>
    /// Код подтверждения email, отправленный на почту игрока.
    /// Удаляется (null) после успешной верификации.
    /// 
    /// Email verification code sent to player's email.
    /// Null after successful verification.
    /// </summary>
    public string? VerificationCode { get; set; }

    /// <summary>
    /// Код двухфакторной аутентификации, отправленный на email.
    /// Удаляется (null) после успешного входа или истечения срока.
    /// 
    /// Two-factor authentication code sent to email.
    /// Null after successful login or expiration.
    /// </summary>
    public string? TwoFactorCode { get; set; }

    /// <summary>
    /// Связь с историей транзакций игрока (финансовые операции).
    /// Relationship to player's transaction history.
    /// </summary>
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();

    /// <summary>
    /// Флаг верификации email адреса игрока.
    /// Должен быть true для полной активации учетной записи.
    /// 
    /// Whether the player's email has been verified.
    /// Must be true for account to be fully active.
    /// </summary>
    public bool IsVerified { get; set; } = false;

    /// <summary>
    /// Текущий баланс игрока в игровой валюте.
    /// Player's current balance in the game currency.
    /// </summary>
    public decimal Balance { get; set; }

    /// <summary>
    /// Текущий уровень персонажа игрока.
    /// Player's current character level.
    /// </summary>
    public int Level { get; set; } = 1;

    /// <summary>
    /// Текущие очки опыта (XP) игрока.
    /// Player's current experience points.
    /// </summary>
    public long CurrentXp { get; set; }

    /// <summary>
    /// Количество XP, необходимое для достижения следующего уровня.
    /// Experience points required to reach the next level.
    /// </summary>
    public long XpToNextLevel { get; set; } = 100;

    /// <summary>
    /// Флаг включения двухфакторной аутентификации (2FA).
    /// По умолчанию отключена для новых пользователей.
    /// 
    /// Flag for enabling two-factor authentication (2FA).
    /// Disabled by default for new users.
    /// </summary>
    public bool IsTwoFactorEnabled { get; set; } = false;

    /// <summary>
    /// Добавляет финансовую транзакцию и обновляет баланс игрока.
    /// При сбережении добавляет 10% от суммы в XP.
    /// При расходе уменьшает баланс на сумму операции.
    /// 
    /// Adds a financial transaction and updates the player's balance.
    /// If the transaction is Saving, adds 10% of amount as XP.
    /// If the transaction is Expense, decreases balance by the amount.
    /// </summary>
    /// <param name="amount">Сумма транзакции / The transaction amount.</param>
    /// <param name="type">Тип транзакции (Сбережение/Расход) / The type of transaction.</param>
    public void AddTransaction(decimal amount, TransactionType type)
    {
        if (type == TransactionType.Saving)
        {
            Balance += amount;
            AddXp((long)(amount * 0.1m));
        }
        else if (type == TransactionType.Expense)
        {
            Balance -= amount;
        }
    }

    /// <summary>
    /// Добавляет очки опыта (XP) и обрабатывает логику повышения уровня.
    /// Увеличивает уровень и обнуляет XP при достижении порога.
    /// Требование XP к следующему уровню увеличивается на 50%.
    /// 
    /// Adds experience points and handles level-up logic.
    /// Increases level and resets XP when threshold is reached.
    /// XP requirement for next level increases by 50%.
    /// </summary>
    /// <param name="xp">Количество XP для добавления / Experience points to add.</param>
    public void AddXp(long xp)
    {
        CurrentXp += xp;

        while (CurrentXp >= XpToNextLevel)
        {
            CurrentXp -= XpToNextLevel;
            Level++;
            XpToNextLevel = (long)(XpToNextLevel * 1.5m);
        }
    }
}
