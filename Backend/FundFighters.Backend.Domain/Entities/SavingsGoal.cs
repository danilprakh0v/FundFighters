/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: SavingsGoal.cs
Расположение: Backend/FundFighters.Backend.Domain/Entities/
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
/// Представляет цель, которую игрок хочет достичь путем накопления средств.
/// </summary>
public class SavingsGoal : BaseEntity
{
    /// <summary>
    /// Идентификатор игрока-владельца цели.
    /// </summary>
    public required string PlayerId { get; set; }

    /// <summary>
    /// Название финансовой цели или имя врага.
    /// </summary>
    public string GoalName { get; set; } = string.Empty;

    /// <summary>
    /// Описание цели.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Целевая сумма накопления (в рублях).
    /// </summary>
    public decimal TargetAmount { get; set; }

    /// <summary>
    /// Текущая накопленная сумма (в рублях).
    /// </summary>
    public decimal CurrentAmount { get; set; }

    /// <summary>
    /// URL изображения цели/врага.
    /// </summary>
    public string ImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Флаг активности цели.
    /// </summary>
    public bool IsActive { get; set; } = true;

    /// <summary>
    /// Дата завершения цели (если достигнута).
    /// </summary>
    public DateTime? CompletedDate { get; set; }

    /// <summary>
    /// Общее количество "жизней" врага (сердец) в интерфейсе.
    /// </summary>
    public int TotalHearts { get; set; } = 10;

    /// <summary>
    /// Количество поверженных сердец (прогресс в долях).
    /// </summary>
    public int DefeatedHearts { get; set; }

    /// <summary>
    /// Расчет процента выполнения цели.
    /// </summary>
    /// <returns>Процент прогресса.</returns>
    public decimal GetProgressPercentage()
    {
        if (TargetAmount == 0) return 0;
        return (CurrentAmount / TargetAmount) * 100;
    }

    /// <summary>
    /// Расчет суммы, оставшейся до достижения цели.
    /// </summary>
    /// <returns>Оставшаяся сумма.</returns>
    public decimal GetRemainingAmount()
    {
        return TargetAmount - CurrentAmount;
    }
}
