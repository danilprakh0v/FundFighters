/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Player.cs
Расположение: Backend/FundFighters.Backend.Domain/Entities/
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
/// </summary>
public class Player : BaseEntity
{
    /// <summary>
    /// Имя пользователя (nickname) игрока для отображения в интерфейсе.
    /// </summary>
    public string Username { get; set; } = string.Empty;

    /// <summary>
    /// Email адрес игрока (обязателен для аутентификации и верификации).
    /// </summary>
    public required string Email { get; set; }

    /// <summary>
    /// Хешированный пароль игрока.
    /// </summary>
    public string PasswordHash { get; set; } = string.Empty;

    /// <summary>
    /// Код подтверждения email, отправленный на почту игрока.
    /// </summary>
    public string? VerificationCode { get; set; }

    /// <summary>
    /// Код двухфакторной аутентификации, отправленный на email.
    /// </summary>
    public string? TwoFactorCode { get; set; }

    /// <summary>
    /// Список финансовых транзакций игрока.
    /// </summary>
    public ICollection<Transaction> Transactions { get; set; } = new List<Transaction>();

    /// <summary>
    /// Флаг верификации email адреса игрока.
    /// </summary>
    public bool IsVerified { get; set; } = false;

    /// <summary>
    /// Текущий баланс игрока в игровой валюте.
    /// </summary>
    public decimal Balance { get; set; }

    /// <summary>
    /// Текущий уровень персонажа игрока.
    /// </summary>
    public int Level { get; set; } = 1;

    /// <summary>
    /// Текущие очки опыта (XP) игрока.
    /// </summary>
    public long CurrentXp { get; set; }

    /// <summary>
    /// Количество XP, необходимое для достижения следующего уровня.
    /// </summary>
    public long XpToNextLevel { get; set; } = 100;

    /// <summary>
    /// Флаг включения двухфакторной аутентификации (2FA).
    /// </summary>
    public bool IsTwoFactorEnabled { get; set; } = false;

    /// <summary>
    /// Добавляет финансовую транзакцию и обновляет баланс игрока.
    /// При сбережении добавляет 10% от суммы в очки опыта (XP).
    /// </summary>
    /// <param name="amount">Сумма транзакции.</param>
    /// <param name="type">Тип транзакции (Сбережение/Расход).</param>
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
    /// </summary>
    /// <param name="xp">Количество XP для добавления.</param>
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
