/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DashboardDto.cs
Расположение: FundFighters.Backend.Application/DTOs/
Назначение: DTO для главного экрана со всеми данными.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

namespace FundFighters.Backend.Application.DTOs;

/// <summary>
/// DTO для главного экрана со всеми необходимыми данными.
/// 
/// DTO for the main dashboard screen with all necessary data.
/// </summary>
public class DashboardDto
{
    /// <summary>
    /// Информация о пользователе.
    /// User information.
    /// </summary>
    public UserInfoDto UserInfo { get; set; } = new();

    /// <summary>
    /// Информация о балансе и доходах/расходах.
    /// Balance and income/expense information.
    /// </summary>
    public BalanceInfoDto BalanceInfo { get; set; } = new();

    /// <summary>
    /// Активная цель сбережения (враг).
    /// The active savings goal (enemy).
    /// </summary>
    public SavingsGoalDto? ActiveGoal { get; set; }

    /// <summary>
    /// Список последних транзакций.
    /// List of recent transactions.
    /// </summary>
    public List<TransactionDto> RecentTransactions { get; set; } = new();

    /// <summary>
    /// Список последних боев.
    /// List of recent battles.
    /// </summary>
    public List<BattleDto> RecentBattles { get; set; } = new();

    /// <summary>
    /// Разбивка расходов по категориям.
    /// Expense breakdown by categories.
    /// </summary>
    public List<ExpenseCategoryDto> ExpenseCategories { get; set; } = new();
}

public class UserInfoDto
{
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

public class BalanceInfoDto
{
    /// <summary>
    /// Общий баланс.
    /// Total balance.
    /// </summary>
    public decimal TotalBalance { get; set; }

    /// <summary>
    /// Доход за этот месяц.
    /// Income for this month.
    /// </summary>
    public decimal MonthlyIncome { get; set; }

    /// <summary>
    /// Процент изменения доходов.
    /// Income change percentage.
    /// </summary>
    public decimal IncomeChangePercent { get; set; }

    /// <summary>
    /// Расходы за этот месяц.
    /// Expenses for this month.
    /// </summary>
    public decimal MonthlyExpense { get; set; }

    /// <summary>
    /// Процент изменения расходов.
    /// Expense change percentage.
    /// </summary>
    public decimal ExpenseChangePercent { get; set; }
}

public class SavingsGoalDto
{
    public string Id { get; set; } = string.Empty;
    public string GoalName { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public decimal TargetAmount { get; set; }
    public decimal CurrentAmount { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public decimal ProgressPercentage { get; set; }
    public decimal RemainingAmount { get; set; }
    public int TotalHearts { get; set; }
    public int DefeatedHearts { get; set; }
}

public class TransactionDto
{
    public string Id { get; set; } = string.Empty;
    public decimal Amount { get; set; }
    public string Type { get; set; } = string.Empty; // Income or Expense
    public string Category { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string IconUrl { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class BattleDto
{
    public string Id { get; set; } = string.Empty;
    public string SavingsGoalId { get; set; } = string.Empty;
    public decimal DamageDealt { get; set; }
    public long XpGained { get; set; }
    public string BattleResult { get; set; } = "won";
    public DateTime BattleDate { get; set; }
    public string EnemyName { get; set; } = string.Empty;
    public string EnemyImageUrl { get; set; } = string.Empty;
}

public class ExpenseCategoryDto
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string ColorHex { get; set; } = string.Empty;
    public string IconUrl { get; set; } = string.Empty;
    public decimal TotalAmount { get; set; }
    public decimal Percentage { get; set; }
    public int SortOrder { get; set; }
}
