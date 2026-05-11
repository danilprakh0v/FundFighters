/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Transaction.cs
Расположение: Backend/FundFighters.Backend.Domain/Entities/
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
/// </summary>
public class Transaction : BaseEntity
{
    /// <summary>
    /// Название транзакции (например, "Яндекс Плюс", "Зарплата", "Netflix").
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Категория транзакции для группировки в интерфейсе.
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Сумма транзакции (в игровой валюте).
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// Тип транзакции (Расход или Сбережение).
    /// </summary>
    public TransactionType Type { get; set; }

    /// <summary>
    /// Дата и время совершения транзакции.
    /// </summary>
    public DateTime Date { get; set; }

    /// <summary>
    /// URL иконки для отображения в ленте транзакций.
    /// </summary>
    public string? IconUrl { get; set; }

    /// <summary>
    /// Внешний ключ игрока.
    /// </summary>
    public int PlayerId { get; set; }

    /// <summary>
    /// Навигационное свойство игрока.
    /// </summary>
    public Player? Player { get; set; }
}
