/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DashboardController.cs
Расположение: FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для получения данных главного экрана.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Application.Features.Dashboard.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FundFighters.Backend.API.Controllers;

/// <summary>
/// Контроллер главного экрана (Dashboard) приложения.
/// Предоставляет эндпоинты для получения данных для отображения на главном экране.
/// 
/// Dashboard controller for the main screen of the application.
/// Provides endpoints for retrieving data to display on the main screen.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DashboardController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly ILogger<DashboardController> _logger;

    public DashboardController(IMediator mediator, ILogger<DashboardController> logger)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    /// <summary>
    /// Получает все данные для главного экрана.
    /// Включает информацию о пользователе, балансе, целях, транзакциях, боях и расходах.
    /// 
    /// Get all dashboard data.
    /// Includes user info, balance, goals, transactions, battles, and expenses.
    /// </summary>
    /// <returns>Dashboard data with all sections.</returns>
    [HttpGet("data")]
    [ProducesResponseType(typeof(DashboardDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetDashboard()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                _logger.LogWarning("User ID not found in claims");
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            _logger.LogInformation($"Dashboard retrieved successfully for user: {playerId}");
            return Ok(dashboard);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning($"User not found: {ex.Message}");
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving dashboard: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving dashboard data" });
        }
    }

    /// <summary>
    /// Получает только информацию о балансе.
    /// 
    /// Get balance information only.
    /// </summary>
    /// <returns>Balance and income/expense info.</returns>
    [HttpGet("balance")]
    [ProducesResponseType(typeof(BalanceInfoDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetBalance()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.BalanceInfo);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving balance: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving balance" });
        }
    }

    /// <summary>
    /// Получает активную цель сбережения (врага).
    /// 
    /// Get the active savings goal (enemy).
    /// </summary>
    /// <returns>Active savings goal data.</returns>
    [HttpGet("active-goal")]
    [ProducesResponseType(typeof(SavingsGoalDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetActiveGoal()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            if (dashboard.ActiveGoal == null)
            {
                return NotFound(new { message = "No active savings goal found" });
            }

            return Ok(dashboard.ActiveGoal);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving active goal: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving active goal" });
        }
    }

    /// <summary>
    /// Получает список недавних транзакций.
    /// 
    /// Get list of recent transactions.
    /// </summary>
    /// <returns>List of recent transactions.</returns>
    [HttpGet("recent-transactions")]
    [ProducesResponseType(typeof(List<TransactionDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetRecentTransactions()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.RecentTransactions);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving recent transactions: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving transactions" });
        }
    }

    /// <summary>
    /// Получает список недавних боев.
    /// 
    /// Get list of recent battles.
    /// </summary>
    /// <returns>List of recent battles.</returns>
    [HttpGet("recent-battles")]
    [ProducesResponseType(typeof(List<BattleDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetRecentBattles()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.RecentBattles);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving recent battles: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving battles" });
        }
    }

    /// <summary>
    /// Получает разбивку расходов по категориям.
    /// 
    /// Get expense breakdown by categories.
    /// </summary>
    /// <returns>List of expense categories with totals.</returns>
    [HttpGet("expense-categories")]
    [ProducesResponseType(typeof(List<ExpenseCategoryDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> GetExpenseCategories()
    {
        try
        {
            var playerId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerId))
            {
                return Unauthorized(new { message = "User identification failed" });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.ExpenseCategories);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Error retrieving expense categories: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "An error occurred while retrieving expense categories" });
        }
    }
}
