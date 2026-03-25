/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GameController.cs
Расположение: FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для операций управления боевой системой.
            Предоставляет эндпоинты для получения состояния боя и обработки транзакций.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.API.DTOs.Requests;
using FundFighters.Backend.Application.DTOs;
using FundFighters.Backend.Application.Features.Battle.Commands;
using FundFighters.Backend.Application.Features.Battle.Queries;
using FundFighters.Backend.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace FundFighters.Backend.API.Controllers;

/// <summary>
/// REST API контроллер для управления игровыми операциями и боевой системой.
/// Предоставляет эндпоинты для iOS приложения для получения состояния боя и обработки финансовых транзакций.
/// Использует паттерн CQRS через MediatR для обработки запросов.
/// 
/// REST API controller for game operations and battle mechanics management.
/// Provides endpoints for iOS application to get battle state and process transactions.
/// Uses CQRS pattern through MediatR for request processing.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class GameController : ControllerBase
{
    /// <summary>
    /// MediatR медиатор для отправки команд и запросов.
    /// MediatR mediator for sending commands and queries.
    /// </summary>
    private readonly IMediator _mediator;

    /// <summary>
    /// Инжектирует MediatR медиатор через конструктор.
    /// Injects MediatR mediator through constructor.
    /// </summary>
    /// <param name="mediator">MediatR медиатор.</param>
    public GameController(IMediator mediator)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
    }

    /// <summary>
    /// Получает текущее состояние боя для указанного игрока.
    /// Включает баланс игрока, уровень, информацию о враге и его здоровье.
    /// 
    /// Gets the current battle state for a player.
    /// Includes player balance, level, and enemy status.
    /// </summary>
    /// <param name="playerId">ID игрока / The ID of the player.</param>
    /// <returns>Состояние боя (DTO) / Battle state (DTO)</returns>
    [HttpGet("state")]
    [ProducesResponseType(typeof(BattleStateDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<BattleStateDto>> GetBattleState([FromQuery] int playerId)
    {
        try
        {
            var query = new GetBattleStateQuery(playerId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Обрабатывает финансовую транзакцию в боевой системе.
    /// При сбережении денег враг получает урон и игрок получает опыт.
    /// При трате денег уменьшается только баланс игрока.
    /// 
    /// Processes a financial transaction in the battle.
    /// On saving: enemy takes damage and player gains XP.
    /// On expense: only player balance decreases.
    /// </summary>
    /// <param name="request">Детали транзакции / Transaction details.</param>
    /// <returns>Обновлённое состояние боя / Updated battle state.</returns>
    [HttpPost("transaction")]
    [ProducesResponseType(typeof(BattleStateDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<BattleStateDto>> ProcessTransaction([FromBody] ProcessTransactionRequest request)
    {
        try
        {
            // Валидация запроса / Request validation
            if (request.Amount <= 0)
            {
                return BadRequest(new { message = "Сумма должна быть больше 0. / Amount must be greater than 0." });
            }

            if (request.Type < 0 || request.Type > 1)
            {
                return BadRequest(new { message = "Неверный тип транзакции. Используйте 0 для Расхода или 1 для Дохода. / Invalid transaction type. Use 0 for Expense or 1 for Saving." });
            }

            if (string.IsNullOrWhiteSpace(request.Title))
            {
                return BadRequest(new { message = "Название транзакции не может быть пустым. / Transaction title cannot be empty." });
            }

            if (string.IsNullOrWhiteSpace(request.Category))
            {
                return BadRequest(new { message = "Категория транзакции не может быть пустой. / Transaction category cannot be empty." });
            }

            var command = new ProcessTransactionCommand(
                request.PlayerId,
                request.Amount,
                (TransactionType)request.Type,
                request.Title,
                request.Category
            );

            var result = await _mediator.Send(command);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
