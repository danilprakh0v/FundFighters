/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GameController.cs
Расположение: Backend/FundFighters.Backend.API/Controllers/
Назначение: REST API контроллер для операций управления боевой системой.
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
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace FundFighters.Backend.API.Controllers;

/// <summary>
/// REST API контроллер для управления игровыми операциями и боевой системой.
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class GameController : ControllerBase
{
    private readonly IMediator _mediator;

    public GameController(IMediator mediator)
    {
        _mediator = mediator ?? throw new ArgumentNullException(nameof(mediator));
    }

    /// <summary>
    /// Получение текущего состояния боя для игрока.
    /// </summary>
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
    /// Обработка финансовой транзакции в боевой системе.
    /// </summary>
    [HttpPost("transaction")]
    [ProducesResponseType(typeof(BattleStateDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<BattleStateDto>> ProcessTransaction([FromBody] ProcessTransactionRequest request)
    {
        try
        {
            var playerIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerIdClaim) || !int.TryParse(playerIdClaim, out var playerId))
            {
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            if (request.Amount <= 0)
            {
                return BadRequest(new { message = "Сумма должна быть больше 0." });
            }

            var command = new ProcessTransactionCommand(
                playerId,
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

    /// <summary>
    /// Удаление транзакции и корректировка баланса игрока.
    /// </summary>
    [HttpDelete("transaction/{id}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> DeleteTransaction(int id)
    {
        try
        {
            var playerIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(playerIdClaim) || !int.TryParse(playerIdClaim, out var playerId))
            {
                return Unauthorized(new { message = "Ошибка идентификации пользователя." });
            }

            var command = new DeleteTransactionCommand(id, playerId);
            var result = await _mediator.Send(command);
            if (!result) return NotFound();
            return Ok();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
