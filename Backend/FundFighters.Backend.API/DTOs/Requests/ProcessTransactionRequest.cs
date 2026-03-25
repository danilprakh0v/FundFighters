/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: ProcessTransactionRequest.cs
Расположение: FundFighters.Backend.API/DTOs/Requests/
Назначение: Модель запроса для обработки финансовой транзакции в боевой системе.
            Отправляется мобильным клиентом на сервер для выполнения операции.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.API.DTOs.Requests;

/// <summary>
/// Модель запроса для обработки финансовой транзакции игроком.
/// Содержит все данные о операции: тип, сумму, название и категорию.
/// Отправляется от мобильного клиента для выполнения операции на сервере.
/// 
/// Request model for processing a financial transaction in the battle.
/// Contains all transaction data: type, amount, title, and category.
/// Sent from mobile client to server for transaction processing.
/// </summary>
public class ProcessTransactionRequest
{
    /// <summary>
    /// Идентификатор игрока, выполняющего транзакцию.
    /// The ID of the player making the transaction.
    /// </summary>
    public int PlayerId { get; set; }

    /// <summary>
    /// Сумма финансовой операции (в игровой валюте).
    /// The amount of the financial transaction.
    /// </summary>
    public decimal Amount { get; set; }

    /// <summary>
    /// Тип транзакции: 0 = Расход (Expense), 1 = Сбережение (Saving).
    /// Используется для определения, увеличивается или уменьшается баланс.
    /// 
    /// Transaction type: 0 = Expense, 1 = Saving.
    /// Used to determine if balance increases or decreases.
    /// </summary>
    public int Type { get; set; }

    /// <summary>
    /// Название/описание транзакции (например, "Netflix", "Зарплата", "Groceries").
    /// Title/description of the transaction (e.g., "Netflix", "Salary", "Groceries").
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Категория транзакции для группировки (например, "Subscriptions", "Income", "Food").
    /// Category of the transaction for grouping (e.g., "Subscriptions", "Income", "Food").
    /// </summary>
    public string Category { get; set; } = string.Empty;
}
