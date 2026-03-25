/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GetBattleStateQuery.cs
Расположение: FundFighters.Backend.Application/Features/Battle/Queries/
Назначение: CQRS запрос для получения текущего состояния боевой системы.
            Реализует паттерн Query в CQRS архитектуре.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using MediatR;

namespace FundFighters.Backend.Application.Features.Battle.Queries;

/// <summary>
/// CQRS запрос для получения полного состояния боя для конкретного игрока.
/// Возвращает BattleStateDto с информацией о балансе, уровне и враге.
/// Является immutable и используется для чтения данных без побочных эффектов.
/// 
/// CQRS query to retrieve the current battle state for a player.
/// Returns BattleStateDto with balance, level, and enemy information.
/// Is immutable and used for read operations without side effects.
/// </summary>
public class GetBattleStateQuery : IRequest<BattleStateDto>
{
    /// <summary>
    /// Идентификатор игрока, для которого требуется получить состояние боя.
    /// The ID of the player whose battle state should be retrieved.
    /// </summary>
    public int PlayerId { get; set; }

    /// <summary>
    /// Конструктор для инициализации запроса с ID игрока.
    /// Constructor to initialize query with player ID.
    /// </summary>
    /// <param name="playerId">ID игрока / Player ID.</param>
    public GetBattleStateQuery(int playerId)
    {
        PlayerId = playerId;
    }
}
