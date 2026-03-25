/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Transaction.cs
Расположение: FundFighters.Backend.Domain/Entities/
Назначение: Модель предметной области, представляющая финансовую транзакцию.
            Хранит информацию о каждой операции (доход/расход) игрока.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Enums;

namespace FundFighters.Backend.Domain.Entities;

/// <summary>
/// Модель предметной области, представляющая финансовую транзакцию игрока.
/// Хранит информацию о каждой денежной операции (доход или расход).
/// Связана с игроком через отношение "многие-к-одному" (Many-to-One).
/// Содержит название и категорию для отображения в UI приложения.
/// 
/// Domain model representing a financial transaction associated with a player.
/// Stores information about each monetary operation (income or expense).
/// Related to player through Many-to-One relationship.
/// Contains title and category for UI display.
/// </summary>
public class Transaction : BaseEntity
{
    /// <summary>
    /// Название транзакции (например, "Yandex Plus", "Зарплата", "Netflix").
    /// Title/name of the transaction (e.g., "Yandex Plus", "Salary", "Netflix").
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Категория транзакции для группировки в UI (например, "Subscriptions", "Food", "Income").
    /// Category of the transaction for UI grouping (e.g., "Subscriptions", "Food", "Income").
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Сумма транзакции (в валюте игры).
    /// Transaction amount (in game currency).
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// Тип транзакции (Расход или Доход).
    /// Type of transaction (Expense or Saving).
    /// </summary>
    public TransactionType Type { get; set; }

    /// <summary>
    /// Дата и время совершения транзакции.
    /// Date and time when the transaction was made.
    /// </summary>
    public DateTime Date { get; set; }

    /// <summary>
    /// Опциональный URL иконки бренда (например, для логотипа Netflix).
    /// Optional URL to brand icon (e.g., Netflix logo).
    /// </summary>
    public string? IconUrl { get; set; }

    /// <summary>
    /// Внешний ключ - идентификатор игрока, совершившего транзакцию.
    /// Foreign key - ID of the player who made the transaction.
    /// </summary>
    public int PlayerId { get; set; }

    /// <summary>
    /// Навигационное свойство для доступа к связанному игроку.
    /// Navigation property to access related player.
    /// </summary>
    public Player? Player { get; set; }
}
