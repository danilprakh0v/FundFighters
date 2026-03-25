/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Enemy.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Богатая модель предметной области, представляющая врага/вызов.
            Управляет здоровьем врага и состоянием поражения.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Богатая модель предметной области, представляющая врага/финансовый вызов.
/// Отвечает за управление здоровьем врага и отслеживание его состояния поражения.
/// Инкапсулирует логику нанесения урона и определения поражения врага.
/// 
/// Rich domain model representing an enemy/challenge in the battle mechanics.
/// Manages enemy health and tracks defeat state.
/// Encapsulates damage logic and defeat determination.
/// </summary>
public class Enemy : BaseEntity
{
    /// <summary>
    /// Имя врага (например, "Monthly Budget Dragon").
    /// Name of the enemy (e.g., "Monthly Budget Dragon").
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Максимальное здоровье врага (целевая сумма для финансовой цели).
    /// Maximum health points (target amount for the financial goal).
    /// </summary>
    public decimal MaxHp { get; set; }

    /// <summary>
    /// Текущее здоровье врага (уменьшается при получении урона).
    /// Current health points of the enemy (decreases with damage).
    /// </summary>
    public decimal CurrentHp { get; set; }

    /// <summary>
    /// URL изображения врага для отображения в мобильном приложении.
    /// URL to the enemy's image for displaying in mobile app.
    /// </summary>
    public string ImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Флаг, указывающий, был ли враг побеждён (здоровье ≤ 0).
    /// Flag indicating whether the enemy has been defeated (health ≤ 0).
    /// </summary>
    public bool IsDefeated { get; set; }

    /// <summary>
    /// Враг получает урон (здоровье уменьшается на указанное значение).
    /// Если здоровье становится ≤ 0, враг помечается как побеждённый.
    /// 
    /// Enemy takes damage (health decreases by specified amount).
    /// If health becomes ≤ 0, enemy is marked as defeated.
    /// </summary>
    /// <param name="amount">Величина урона. / Damage amount.</param>
    public void TakeDamage(decimal amount)
    {
        CurrentHp -= amount;
        if (CurrentHp <= 0)
        {
            CurrentHp = 0;
            IsDefeated = true;
        }
    }
}
