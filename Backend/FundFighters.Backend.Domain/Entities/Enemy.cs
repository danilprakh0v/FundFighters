/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Enemy.cs
Расположение: Backend/FundFighters.Backend.Domain/Entities/
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
/// Отвечает за управление здоровьем врага и отслеживание его состояния.
/// Инкапсулирует логику нанесения урона и определения поражения врага.
/// </summary>
public class Enemy : BaseEntity
{
    /// <summary>
    /// Имя врага (например, "Дракон месячного бюджета").
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Максимальное здоровье врага (целевая сумма финансовой цели).
    /// </summary>
    public decimal MaxHp { get; set; }

    /// <summary>
    /// Текущее здоровье врага (уменьшается при накоплении средств).
    /// </summary>
    public decimal CurrentHp { get; set; }

    /// <summary>
    /// URL изображения врага для мобильного приложения.
    /// </summary>
    public string ImageUrl { get; set; } = string.Empty;

    /// <summary>
    /// Флаг, указывающий, побежден ли враг.
    /// </summary>
    public bool IsDefeated { get; set; }

    /// <summary>
    /// Нанесение урона врагу (уменьшение здоровья).
    /// </summary>
    /// <param name="amount">Величина урона.</param>
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
