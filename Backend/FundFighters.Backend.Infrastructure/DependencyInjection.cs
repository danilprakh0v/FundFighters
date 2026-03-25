/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: DependencyInjection.cs
Расположение: FundFighters.Backend.Infrastructure/
Назначение: Методы расширения для внедрения зависимостей инфраструктурного слоя.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using FundFighters.Backend.Application.Interfaces;
using FundFighters.Backend.Domain.Interfaces;
using FundFighters.Backend.Infrastructure.Data;
using FundFighters.Backend.Infrastructure.Repositories;
using FundFighters.Backend.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace FundFighters.Backend.Infrastructure;

/// <summary>
/// Методы расширения для внедрения зависимостей инфраструктурного слоя.
/// Регистрирует все инфраструктурные сервисы, включая БД, репозитории и сервис отправки email.
/// 
/// Dependency injection extension methods for Infrastructure layer.
/// Registers all infrastructure services including database, repositories, and email service.
/// </summary>
public static class DependencyInjection
{
    /// <summary>
    /// Добавляет сервисы инфраструктурного слоя в контейнер внедрения зависимостей.
    /// Конфигурирует Entity Framework Core, репозитории и внешние сервисы.
    /// 
    /// Adds Infrastructure layer services to the dependency injection container.
    /// Configures Entity Framework Core, repositories, and external services.
    /// </summary>
    /// <param name="services">Коллекция сервисов для регистрации (The service collection to register services with)</param>
    /// <param name="configuration">Конфигурация приложения (The application configuration)</param>
    /// <returns>Модифицированная коллекция сервисов для цепочки вызовов (The modified service collection for method chaining)</returns>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Регистрирует Entity Framework Core с PostgreSQL
        // Register Entity Framework Core with PostgreSQL
        services.AddDbContext<AppDbContext>(options =>
        {
            var connectionString = configuration.GetConnectionString("DefaultConnection");
            options.UseNpgsql(connectionString);
        });

        // Регистрирует репозитории
        // Register repositories
        services.AddScoped<IGameRepository, GameRepository>();

        // Регистрирует сервис отправки email
        // Register email service
        services.AddScoped<IEmailService, SmtpEmailService>();

        // Регистрирует сервис JWT
        // Register JWT service
        services.AddScoped<IJwtService, JwtService>();

        // Регистрирует инициализатор БД как hosted service
        // Register database initializer as hosted service
        services.AddHostedService<DbInitializerHostedService>();

        return services;
    }
}

/// <summary>
/// Hosted сервис для инициализации БД с seed данными при запуске приложения.
/// 
/// Hosted service for initializing the database with seed data on application startup.
/// </summary>
public class DbInitializerHostedService : IHostedService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly ILogger<DbInitializerHostedService> _logger;

    public DbInitializerHostedService(IServiceProvider serviceProvider, ILogger<DbInitializerHostedService> logger)
    {
        _serviceProvider = serviceProvider;
        _logger = logger;
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            try
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
                await DbInitializer.InitializeAsync(dbContext);
                _logger.LogInformation("Database initialization completed successfully.");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Database initialization failed. Check PostgreSQL connection:");
                _logger.LogError($"Host: localhost, Port: 5432, Database: fundfighters");
                _logger.LogError($"Make sure PostgreSQL is running. Error: {ex.GetType().Name} - {ex.Message}");
                if (ex.InnerException != null)
                {
                    _logger.LogError($"Inner exception: {ex.InnerException.Message}");
                }
            }
        }
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
}
