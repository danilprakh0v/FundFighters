/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DashboardController.cs
Расположение: Backend/FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для получения данных главного экрана.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
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
    /// Получение всех данных для главного экрана.
    /// </summary>
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
                _logger.LogWarning("ID пользователя не найден в Claims.");
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            _logger.LogInformation($"Данные Dashboard успешно получены для: {playerId}");
            return Ok(dashboard);
        }
        catch (InvalidOperationException ex)
        {
            _logger.LogWarning($"Пользователь не найден: {ex.Message}");
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении данных Dashboard: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении данных Dashboard." });
        }
    }

    /// <summary>
    /// Получение информации о балансе.
    /// </summary>
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
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.BalanceInfo);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении баланса: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении баланса." });
        }
    }

    /// <summary>
    /// Получение активной цели сбережения (врага).
    /// </summary>
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
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            if (dashboard.ActiveGoal == null)
            {
                return NotFound(new { message = "Активная цель сбережения не найдена." });
            }

            return Ok(dashboard.ActiveGoal);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении активной цели: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении активной цели." });
        }
    }

    /// <summary>
    /// Получение списка последних транзакций.
    /// </summary>
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
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.RecentTransactions);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении транзакций: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении транзакций." });
        }
    }

    /// <summary>
    /// Получение списка последних боев.
    /// </summary>
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
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.RecentBattles);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении боев: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении боев." });
        }
    }

    /// <summary>
    /// Получение разбивки расходов по категориям.
    /// </summary>
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
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var query = new GetDashboardQuery { PlayerId = playerId };
            var dashboard = await _mediator.Send(query);

            return Ok(dashboard.ExpenseCategories);
        }
        catch (Exception ex)
        {
            _logger.LogError($"Ошибка при получении категорий расходов: {ex.Message}");
            return StatusCode(StatusCodes.Status500InternalServerError,
                new { message = "Произошла ошибка при получении категорий расходов." });
        }
    }
}
