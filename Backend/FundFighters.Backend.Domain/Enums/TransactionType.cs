/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: TransactionType.cs
Расположение: FundFighters.Backend.Domain/Enums/
Назначение: Перечисление типов финансовых транзакций в игре.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

namespace FundFighters.Backend.Domain.Enums;

/// <summary>
/// Перечисление типов финансовых операций в боевой системе.
/// Определяет, является ли операция расходом или доходом.
/// 
/// Enumeration of transaction types for financial operations.
/// Defines whether operation is expense or income.
/// </summary>
public enum TransactionType
{
    /// <summary>
    /// Расход денежных средств (трата).
    /// Money spent (expense).
    /// </summary>
    Expense = 0,

    /// <summary>
    /// Доход / сбережение денежных средств.
    /// Money saved or earned (income).
    /// </summary>
    Saving = 1
}
