/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ExpenseCategory.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Модель сущности для категорий расходов.
            Представляет категорию для группировки расходов.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Модель сущности для категорий расходов.
/// Представляет категорию для группировки расходов.
/// 
/// Entity model for expense categories.
/// Represents a category for grouping expenses.
/// </summary>
public class ExpenseCategory : BaseEntity
{
    /// <summary>
    /// ID игрока-владельца категории.
    /// The ID of the player who owns this category.
    /// </summary>
    public required string PlayerId { get; set; }

    /// <summary>
    /// Название категории (е.г., "Еда", "Развлечения", "Подписки").
    /// The name of the category (e.g., "Food", "Entertainment", "Subscriptions").
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Цвет категории (HEX формат, е.г., "#2EA69B").
    /// The color of the category (HEX format, e.g., "#2EA69B").
    /// </summary>
    public string ColorHex { get; set; } = "#2EA69B";

    /// <summary>
    /// URL иконки категории.
    /// The URL of the category icon.
    /// </summary>
    public string IconUrl { get; set; } = string.Empty;

    /// <summary>
    /// Сортировка / порядок отображения.
    /// The sort order for display.
    /// </summary>
    public int SortOrder { get; set; }
}
