/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DependencyInjection.cs
Расположение: FundFighters.Backend.Application/
Назначение: Методы расширения для внедрения зависимостей слоя Application.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application;
using MediatR;
using Microsoft.Extensions.DependencyInjection;

namespace FundFighters.Backend.Application;

/// <summary>
/// Методы расширения для внедрения зависимостей слоя Application.
/// Регистрирует все сервисы приложения, включая обработчики MediatR и валидаторы.
/// 
/// Dependency injection extension methods for Application layer.
/// Registers all application services including MediatR handlers and validators.
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Добавляет сервисы слоя Application в контейнер внедрения зависимостей.
    /// Регистрирует MediatR со всеми обработчиками из сборки Application.
    /// 
    /// Adds Application layer services to the dependency injection container.
    /// Registers MediatR with all handlers from the Application assembly.
    /// </summary>
    /// <param name="services">Коллекция сервисов для регистрации (The service collection to register services with)</param>
    /// <returns>Модифицированная коллекция сервисов для цепочки вызовов (The modified service collection for method chaining)</returns>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        // Регистрирует MediatR со всеми обработчиками из сборки Application
        // Register MediatR with all handlers from the Application assembly
        services.AddMediatR(cfg =>
        {
            cfg.RegisterServicesFromAssembly(typeof(ApplicationAssemblyMarker).Assembly);
        });

        return services;
    }
}
