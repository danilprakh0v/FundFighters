/*
===============================================================================
Проект: FundFighters (iOS UIKit Backend Service)
Файл: Program.cs
Расположение: FundFighters.Backend.API/
Назначение: Точка входа в ASP.NET Core приложение и Composition Root (корень компоновки).
              Конфигурирует все сервисы, зависимости и middleware приложения.
===============================================================================
Дисциплина: Курсовой проект "FundFighters"
Автор: Прахов Данил, БПИ246
Дата создания: 27.01.2026
===============================================================================
*/

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using FundFighters.Backend.Application;
using FundFighters.Backend.Infrastructure;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// ... (Service Registration)

builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen();

// JWT Authentication Configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings.GetValue<string>("SecretKey") ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLong!";
var issuer = jwtSettings.GetValue<string>("Issuer") ?? "FundFighters.Backend";
var audience = jwtSettings.GetValue<string>("Audience") ?? "FundFighters.iOS";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = issuer,
        ValidAudience = audience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
    };
});

builder.Services.AddAuthorization();

builder.Services.AddApplication();
// ... (rest of service registration)

/// <summary>
/// Регистрирует все сервисы инфраструктурного слоя (БД, репозитории, сервис отправки email).
/// 
/// Registers all infrastructure layer services (database, repositories, email service).
/// </summary>
builder.Services.AddInfrastructure(builder.Configuration);

/// <summary>
/// Конфигурирует CORS (Cross-Origin Resource Sharing) для разрешения запросов с iOS приложения.
/// В разработке разрешены запросы из любого источника.
/// 
/// Configures CORS for iOS UIKit application requests.
/// In development, allows requests from any origin.
/// </summary>
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policyBuilder =>
    {
        policyBuilder.AllowAnyOrigin()
            .AllowAnyMethod()
            .AllowAnyHeader();
    });
});

var app = builder.Build();

/*
===============================================================================
ИНИЦИАЛИЗАЦИЯ БАЗЫ ДАННЫХ (Database Initialization)
===============================================================================
База данных инициализируется автоматически через DbInitializerHostedService
при старте приложения.

Database is automatically initialized via DbInitializerHostedService on startup.
*/

/*
===============================================================================
КОНФИГУРАЦИЯ КОНВЕЙЕРА ОБРАБОТКИ ЗАПРОСОВ (HTTP Request Pipeline)
===============================================================================
Порядок важен! Middleware срабатывает в порядке регистрации.
Order matters! Middleware executes in registration order.
*/

/// <summary>
/// Конфигурирует конвейер обработки запросов для разработки.
/// Включает OpenAPI документацию, Swagger UI, CORS и маршрутизацию.
/// 
/// Configures request processing pipeline for development.
/// Includes OpenAPI documentation, Swagger UI, CORS, and routing.
/// </summary>
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}

// HTTPS переадресация для защищённого соединения.
// HTTPS redirection for secure connection.
app.UseHttpsRedirection();

// Активирует CORS политику для запросов с iOS приложения.
// Activates CORS policy for iOS application requests.
app.UseCors("AllowAll");

// Включает аутентификацию и авторизацию.
// Enables authentication and authorization.
app.UseAuthentication();
app.UseAuthorization();

// Маршрутизирует запросы к соответствующим контроллерам.
// Routes requests to appropriate controllers.
app.MapControllers();

// Запуск приложения и прослушивание входящих HTTP запросов.
// Start application and listen for incoming HTTP requests.
app.Run();
