/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: TransactionPreviewDto.cs
Расположение: FundFighters.Backend.Application/DTOs/
Назначение: DTO для отображения краткой информации о транзакции в UI.
            Используется в списке недавних операций (Recent Activity).
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Domain.Enums;

namespace FundFighters.Backend.Application.DTOs;

/// <summary>
/// DTO для передачи информации о транзакции в виде краткого превью.
/// Используется при отображении списка недавних операций в мобильном приложении.
/// Содержит только существенную информацию для UI без лишних деталей.
/// 
/// Data transfer object for transaction preview information.
/// Used when displaying recent activity list in mobile application.
/// Contains only essential information for UI without unnecessary details.
/// </summary>
public class TransactionPreviewDto
{
    /// <summary>
    /// Уникальный идентификатор транзакции.
    /// Unique identifier of the transaction.
    /// </summary>
    public int Id { get; set; }

    /// <summary>
    /// Название/описание транзакции (например, "Yandex Plus", "Зарплата", "Netflix").
    /// Title/description of the transaction (e.g., "Yandex Plus", "Salary", "Netflix").
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Сумма транзакции (в валюте игры).
    /// Amount of the transaction (in game currency).
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// Категория транзакции для группировки в графиках (например, "Subscriptions", "Food", "Income").
    /// Category of the transaction for grouping in charts (e.g., "Subscriptions", "Food", "Income").
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Дата и время совершения транзакции.
    /// Date and time when the transaction was made.
    /// </summary>
    public DateTime Date { get; set; }

    /// <summary>
    /// Тип транзакции (Расход=Expense или Доход=Saving).
    /// Type of transaction (Expense or Saving).
    /// </summary>
    public TransactionType Type { get; set; }

    /// <summary>
    /// Опциональный URL иконки для отображения логотипа бренда рядом с транзакцией.
    /// Optional URL to brand icon for displaying logo next to transaction.
    /// </summary>
    public string? IconUrl { get; set; }
}
