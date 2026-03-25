/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Battle.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Модель сущности для боевых сражений.
            Представляет историю боев игрока против целей (врагов).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Модель сущности для боевых сражений.
/// Представляет историю боев игрока против целей (врагов).
/// 
/// Entity model for battles.
/// Represents the player's battle history against goals (enemies).
/// </summary>
public class Battle : BaseEntity
{
    /// <summary>
    /// ID игрока, участвующего в битве.
    /// The ID of the player who participated in the battle.
    /// </summary>
    public required string PlayerId { get; set; }

    /// <summary>
    /// ID цели (врага), с которым сражался игрок.
    /// The ID of the goal (enemy) the player fought.
    /// </summary>
    public string SavingsGoalId { get; set; } = string.Empty;

    /// <summary>
    /// Количество урона, нанесенного врагу (сбереженные деньги).
    /// The amount of damage dealt to the enemy (money saved).
    /// </summary>
    public decimal DamageDealt { get; set; }

    /// <summary>
    /// Количество опыта, полученного в результате боя.
    /// The experience points gained from the battle.
    /// </summary>
    public long XpGained { get; set; }

    /// <summary>
    /// Статус боя (выиграно/проиграно).
    /// The status of the battle (won/lost).
    /// </summary>
    public string BattleResult { get; set; } = "won"; // won or lost

    /// <summary>
    /// Дата проведения боя.
    /// The date of the battle.
    /// </summary>
    public DateTime BattleDate { get; set; } = DateTime.UtcNow;
}
