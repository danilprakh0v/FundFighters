/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Battle.cs
Расположение: Backend/FundFighters.Backend.Domain/Entities/
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
/// </summary>
public class Battle : BaseEntity
{
    /// <summary>
    /// Идентификатор игрока, участвовавшего в битве.
    /// </summary>
    public required string PlayerId { get; set; }

    /// <summary>
    /// Идентификатор цели (врага), с которым сражался игрок.
    /// </summary>
    public string SavingsGoalId { get; set; } = string.Empty;

    /// <summary>
    /// Количество урона, нанесенного врагу (сбереженные деньги).
    /// </summary>
    public decimal DamageDealt { get; set; }

    /// <summary>
    /// Количество опыта, полученного в результате боя.
    /// </summary>
    public long XpGained { get; set; }

    /// <summary>
    /// Статус боя (won/lost).
    /// </summary>
    public string BattleResult { get; set; } = "won";

    /// <summary>
    /// Дата проведения боя.
    /// </summary>
    public DateTime BattleDate { get; set; } = DateTime.UtcNow;
}
