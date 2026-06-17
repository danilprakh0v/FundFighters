/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ProcessTransactionCommand.cs
Расположение: FundFighters.Backend.Application/Features/Battle/Commands/
Назначение: CQRS команда для обработки финансовой транзакции игроком.
            Реализует паттерн Command в CQRS архитектуре.
            Вызывает изменения в состоянии системы.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Domain.Enums;
using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Commands;

/// <summary>
/// CQRS команда для обработки финансовой транзакции (расход или сбережение).
/// Изменяет состояние игрока: обновляет баланс, опыт (XP) и записывает транзакцию с названием и категорией.
/// Возвращает обновлённое состояние боя после выполнения операции включая список недавних транзакций.
/// 
/// CQRS command to process a financial transaction (expense or saving).
/// Changes player state: updates balance, experience (XP) and records transaction with title and category.
/// Returns updated battle state after transaction processing including recent transactions list.
/// </summary>
public class ProcessTransactionCommand : IRequest<BattleStateDto>
{
    /// <summary>
    /// Идентификатор игрока, выполняющего транзакцию.
    /// The ID of the player making the transaction.
    /// </summary>
    public int PlayerId { get; set; }

    /// <summary>
    /// Сумма финансовой операции.
    /// The amount of the financial transaction.
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// Тип транзакции: Расход (Expense) или Сбережение (Saving).
    /// Определяет, будет ли баланс увеличен или уменьшен.
    /// 
    /// Transaction type: Expense or Saving.
    /// Determines if balance will be increased or decreased.
    /// </summary>
    public TransactionType Type { get; set; }

    /// <summary>
    /// Название/описание транзакции (например, "Yandex Plus", "Netflix", "Зарплата").
    /// Title/description of the transaction (e.g., "Yandex Plus", "Netflix", "Salary").
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Категория транзакции для группировки и аналитики (например, "Subscriptions", "Food", "Income").
    /// Category of the transaction for grouping and analytics (e.g., "Subscriptions", "Food", "Income").
    /// </summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>
    /// Опциональная дата транзакции. Если не указана, используется текущее время.
    /// Optional transaction date. If not provided, current time is used.
    /// </summary>
    public DateTime? Date { get; set; }

    /// <summary>
    /// Конструктор для инициализации команды с данными транзакции.
    /// Constructor to initialize command with transaction data.
    /// </summary>
    /// <param name="playerId">ID игрока / Player ID.</param>
    /// <param name="amount">Сумма операции / Transaction amount.</param>
    /// <param name="type">Тип операции / Transaction type.</param>
    /// <param name="title">Название операции / Transaction title.</param>
    /// <param name="category">Категория операции / Transaction category.</param>
    /// <param name="date">Опциональная дата транзакции / Optional date.</param>
    public ProcessTransactionCommand(int playerId, decimal amount, TransactionType type, string title, string category, DateTime? date = null)
    {
        PlayerId = playerId;
        Amount = amount;
        Type = type;
        Title = title;
        Category = category;
        Date = date;
    }
}
