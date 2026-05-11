/*
===============================================================================
Проект: FundFighters (iOS UIKit [Backend Service])
Файл: GetDashboardQueryHandler.cs
Расположение: Backend/FundFighters.Backend.Application/Features/Dashboard/QueryHandlers/
Назначение: Обработчик запроса данных для главного экрана (Dashboard).
            Агрегирует баланс, цели, транзакции и категории расходов.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Application.Features.Dashboard.Queries;
using FundFighters.Backend.Domain.Enums;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace FundFighters.Backend.Application.Features.Dashboard.QueryHandlers;

/// <summary>
/// Обработчик для получения сводной информации дашборда.
/// Собирает данные о балансе игрока, активной цели сбережений,
/// последних транзакциях и распределении расходов по категориям за текущий месяц.
/// </summary>
public class GetDashboardQueryHandler : IRequestHandler<GetDashboardQuery, DashboardDto>
{
    private readonly IGameRepository _repository;
    private readonly ILogger<GetDashboardQueryHandler> _logger;

    public GetDashboardQueryHandler(
        IGameRepository repository,
        ILogger<GetDashboardQueryHandler> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<DashboardDto> Handle(GetDashboardQuery request, CancellationToken cancellationToken)
    {
        try
        {
            _logger.LogInformation($"Getting dashboard data for player: {request.PlayerId}");

            // Загрузка данных игрока
            var player = await _repository.GetPlayerByIdAsync(request.PlayerId, cancellationToken);
            if (player == null)
            {
                throw new InvalidOperationException($"Player with ID {request.PlayerId} not found.");
            }

            // Параллельная загрузка связанных сущностей
            var transactions = await _repository.GetTransactionsByPlayerIdAsync(request.PlayerId, cancellationToken);
            var goals = await _repository.GetSavingsGoalsByPlayerIdAsync(request.PlayerId, cancellationToken);
            var battles = await _repository.GetBattlesByPlayerIdAsync(request.PlayerId, cancellationToken);
            var categories = await _repository.GetExpenseCategoriesByPlayerIdAsync(request.PlayerId, cancellationToken);

            var now = DateTime.UtcNow;
            // Фильтрация транзакций за текущий месяц для расчета статистики
            var currentMonthTransactions = transactions.Where(t => t.Date.Month == now.Month && t.Date.Year == now.Year).ToList();
            
            var monthlyIncome = currentMonthTransactions.Where(t => t.Type == TransactionType.Saving).Sum(t => t.Amount);
            var monthlyExpense = currentMonthTransactions.Where(t => t.Type == TransactionType.Expense).Sum(t => t.Amount);

            // Поиск первой активной цели
            var activeGoal = goals.FirstOrDefault(g => g.IsActive);

            // Формирование итогового DTO
            var dashboard = new DashboardDto
            {
                UserInfo = new UserInfoDto
                {
                    Username = player.Username,
                    Email = player.Email 
                },
                BalanceInfo = new BalanceInfoDto
                {
                    TotalBalance = player.Balance,
                    MonthlyIncome = monthlyIncome,
                    IncomeChangePercent = 0,
                    MonthlyExpense = monthlyExpense,
                    ExpenseChangePercent = 0
                },
                ActiveGoal = activeGoal != null ? new SavingsGoalDto
                {
                    Id = activeGoal.Id.ToString(),
                    GoalName = activeGoal.GoalName,
                    Description = activeGoal.Description ?? "",
                    TargetAmount = activeGoal.TargetAmount,
                    CurrentAmount = activeGoal.CurrentAmount,
                    ImageUrl = activeGoal.ImageUrl ?? "",
                    ProgressPercentage = activeGoal.TargetAmount > 0 ? (activeGoal.CurrentAmount / activeGoal.TargetAmount) * 100 : 0,
                    RemainingAmount = Math.Max(0, activeGoal.TargetAmount - activeGoal.CurrentAmount),
                    TotalHearts = activeGoal.TotalHearts,
                    DefeatedHearts = activeGoal.DefeatedHearts
                } : null,
                RecentTransactions = transactions.Take(10).Select(t => new TransactionDto {
                    Id = t.Id.ToString(),
                    Amount = t.Type == TransactionType.Expense ? -t.Amount : t.Amount,
                    Type = t.Type.ToString(),
                    Category = t.Category,
                    Description = t.Title,
                    IconUrl = t.IconUrl ?? "",
                    CreatedAt = t.Date
                }).ToList(),
                RecentBattles = battles.Take(5).Select(b => new BattleDto {
                    Id = b.Id.ToString(),
                    SavingsGoalId = b.SavingsGoalId.ToString(),
                    DamageDealt = b.DamageDealt,
                    XpGained = b.XpGained,
                    BattleResult = b.BattleResult,
                    BattleDate = b.BattleDate,
                    EnemyName = "Enemy",
                    EnemyImageUrl = ""
                }).ToList(),
                ExpenseCategories = categories.Select(c => new ExpenseCategoryDto {
                    Id = c.Id.ToString(),
                    Name = c.Name,
                    ColorHex = c.ColorHex,
                    IconUrl = c.IconUrl ?? "",
                    TotalAmount = currentMonthTransactions.Where(t => t.Category == c.Name && t.Type == TransactionType.Expense).Sum(t => t.Amount),
                    Percentage = monthlyExpense > 0 ? (currentMonthTransactions.Where(t => t.Category == c.Name && t.Type == TransactionType.Expense).Sum(t => t.Amount) / monthlyExpense) * 100 : 0,
                    SortOrder = c.SortOrder
                }).ToList()
            };

            return dashboard;
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error getting dashboard data: {ex.Message}");
            throw;
        }
    }
}
