using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Application.Features.Dashboard.Queries;
using FundFighters.Backend.Domain.Enums;
using FundFighters.Backend.Domain.Interfaces;
using MediatR;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace FundFighters.Backend.Application.Features.Dashboard.QueryHandlers;

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
            _logger.LogInformation($"Getting dashboard data for player: {request.PlayerId} (MOCKING DESIGN DATA)");

            var player = await _repository.GetPlayerByIdAsync(request.PlayerId, cancellationToken);
            if (player == null)
            {
                throw new InvalidOperationException($"Player with ID {request.PlayerId} not found.");
            }

            // MOCKING DATA ACCORDING TO DESIGN CONCEPTS
            var dashboard = new DashboardDto
            {
                UserInfo = new UserInfoDto
                {
                    Username = player.Username, // REAL NAME FROM DB
                    Email = player.Email 
                },
                BalanceInfo = new BalanceInfoDto
                {
                    TotalBalance = 145000.99m,
                    MonthlyIncome = 100000m,
                    IncomeChangePercent = 27m,
                    MonthlyExpense = 45000m,
                    ExpenseChangePercent = 12m
                },
                ActiveGoal = new SavingsGoalDto
                {
                    Id = "1",
                    GoalName = "Playstation 5 Slim",
                    Description = "",
                    TargetAmount = 62000m,
                    CurrentAmount = 23250m,
                    ImageUrl = "",
                    ProgressPercentage = 37.5m,
                    RemainingAmount = 38750m,
                    TotalHearts = 8,
                    DefeatedHearts = 3 
                },
                RecentTransactions = new List<TransactionDto>
                {
                    new TransactionDto {
                        Id = "1", Amount = -400m, Type = "Expense", Category = "Subscription",
                        Description = "Yandex Plus Subscription", IconUrl = "yandex_icon", CreatedAt = DateTime.UtcNow.AddHours(-1)
                    },
                    new TransactionDto {
                        Id = "2", Amount = -700m, Type = "Expense", Category = "Subscription",
                        Description = "Spotify Subscription", IconUrl = "spotify_icon", CreatedAt = DateTime.UtcNow.AddHours(-5)
                    },
                    new TransactionDto {
                        Id = "3", Amount = 300m, Type = "Income", Category = "Transfer",
                        Description = "UI/UX Designer Salary", IconUrl = "salary_icon", CreatedAt = DateTime.UtcNow.AddHours(-10)
                    }
                },
                RecentBattles = new List<BattleDto>
                {
                    new BattleDto {
                        Id = "1", SavingsGoalId = "1", DamageDealt = 0m, XpGained = 0,
                        BattleResult = "Pending", BattleDate = DateTime.Today, EnemyName = "Your Nemesis", EnemyImageUrl = "ps5_monster"
                    }
                },
                ExpenseCategories = new List<ExpenseCategoryDto>
                {
                    new ExpenseCategoryDto { Id = "1", Name = "Food", ColorHex = "#33DF72", IconUrl = "", TotalAmount = 12150m, Percentage = 27m, SortOrder = 1 },
                    new ExpenseCategoryDto { Id = "2", Name = "Groceries", ColorHex = "#3D8EFF", IconUrl = "", TotalAmount = 11250m, Percentage = 25m, SortOrder = 2 },
                    new ExpenseCategoryDto { Id = "3", Name = "Entertainment", ColorHex = "#FF8C33", IconUrl = "", TotalAmount = 9000m, Percentage = 20m, SortOrder = 3 },
                    new ExpenseCategoryDto { Id = "4", Name = "Subscriptions", ColorHex = "#FF3D6E", IconUrl = "", TotalAmount = 6750m, Percentage = 15m, SortOrder = 4 },
                    new ExpenseCategoryDto { Id = "5", Name = "Utilities", ColorHex = "#BE33FF", IconUrl = "", TotalAmount = 5850m, Percentage = 13m, SortOrder = 5 }
                }
            };

            _logger.LogInformation($"Design MOCK Dashboard data retrieved successfully for player: {request.PlayerId}");
            return dashboard;
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error getting dashboard data: {ex.Message}");
            throw;
        }
    }
}
