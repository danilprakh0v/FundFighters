/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: SavingsGoal.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Модель сущности для целей сбережения (врагов в игре).
            Представляет цель, которую игрок хочет достичь путем сбережения денег.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Entities;

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Модель сущности для целей сбережения (врагов в игре).
/// Представляет цель, которую игрок хочет достичь путем сбережения денег.
/// 
/// Entity model for savings goals (enemies in the game).
/// Represents a goal that the player wants to achieve by saving money.
/// </summary>
public class SavingsGoal : BaseEntity
{
    /// <summary>
    /// ID игрока-владельца цели.
    /// The ID of the player who owns this goal.
    /// </summary>
    public required string PlayerId { get; set; }

    /// <summary>
    /// Имя цели / врага (е.г., "Playstation 5 Slim").
    /// The name of the goal / enemy (e.g., "Playstation 5 Slim").
    /// </summary>
    public string GoalName { get; set; } = string.Empty;

    /// <summary>
    /// Описание цели.
    /// The description of the goal.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Целевая сумма в рублях.
    /// The target amount in rubles.
    /// </summary>
    public decimal TargetAmount { get; set; }

    /// <summary>
    /// Текущий размер сбережений в рублях.
    /// The current savings amount in rubles.
    /// </summary>
    public decimal CurrentAmount { get; set; }

    /// <summary>
    /// URL изображения врага / цели.
    /// The URL of the enemy / goal image.
    /// </summary>
    public string ImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Статус активности цели.
    /// Whether the goal is active or completed.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Дата завершения цели (если достигнута).
    /// The date when the goal was completed.
    /// </summary>
    public DateTime? CompletedDate { get; set; }

    /// <summary>
    /// Количество "жизней" врага (сердец).
    /// The number of lives (hearts) the enemy has.
    /// </summary>
    public int TotalHearts { get; set; } = 10;

    /// <summary>
    /// Количество поверженных сердец (нанесено урона).
    /// The number of defeated hearts (damage dealt).
    /// </summary>
    public int DefeatedHearts { get; set; }

    /// <summary>
    /// Вычисляет процент прогресса.
    /// Calculates the progress percentage.
    /// </summary>
    public decimal GetProgressPercentage()
    {
        if (TargetAmount == 0) return 0;
        return (CurrentAmount / TargetAmount) * 100;
    }

    /// <summary>
    /// Вычисляет оставшуюся сумму до цели.
    /// Calculates the remaining amount to reach the goal.
    /// </summary>
    public decimal GetRemainingAmount()
    {
        return TargetAmount - CurrentAmount;
    }
}
