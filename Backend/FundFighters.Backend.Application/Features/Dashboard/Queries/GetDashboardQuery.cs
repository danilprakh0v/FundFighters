/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: GetDashboardQuery.cs
Расположение: FundFighters.Backend.Application/Features/Dashboard/Queries/
Назначение: CQRS запрос для получения данных главного экрана.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 15.03.2026
===============================================================================
*/

using FundFighters.Backend.Application.DTOs;
using MediatR;

namespace FundFighters.Backend.Application.Features.Dashboard.Queries;

/// <summary>
/// CQRS запрос для получения всех данных главного экрана.
/// 
/// CQRS query to retrieve all dashboard data.
/// </summary>
public class GetDashboardQuery : IRequest<DashboardDto>
{
    /// <summary>
    /// ID пользователя, для которого нужно получить данные.
    /// The ID of the user for whom to retrieve dashboard data.
    /// </summary>
    public string PlayerId { get; set; } = string.Empty;
}
